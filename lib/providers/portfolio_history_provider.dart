import 'package:flutter/foundation.dart';
import '../models/portfolio_history.dart';
import '../services/storage_service.dart';
import '../services/historical_price_service.dart';
import 'currency_settings_provider.dart';
import 'crypto_price_provider.dart';

class PortfolioHistoryProvider with ChangeNotifier {
  final List<PortfolioSnapshot> _snapshots = [];
  Duration _selectedTimeframe = const Duration(days: 1);
  final StorageService _storageService;
  final HistoricalPriceService _historicalService = HistoricalPriceService();
  Map<String, dynamic> _historicalData = {};
  CurrencySettingsProvider? _lastSettingsProvider;
  static const String _historicalDataCacheKey = 'historical_data_cache';
  static const String _timeframeCacheKey = 'timeframe_cache';

  PortfolioHistoryProvider(this._storageService) {
    _loadSavedData();
    _loadCachedData();
  }

  List<PortfolioSnapshot> get snapshots => _snapshots;
  Duration get selectedTimeframe => _selectedTimeframe;

  // Initialize with settings provider
  void initialize(CurrencySettingsProvider settingsProvider) {
    if (_lastSettingsProvider == null) {
      _lastSettingsProvider = settingsProvider;
      // Load cached data first, then fetch new data
      _loadCachedData().then((_) {
        loadHistoricalData(settingsProvider);
      });
    }
  }

  Future<void> _loadCachedData() async {
    try {
      // Load cached timeframe
      final cachedTimeframeStr = _storageService.loadString(_timeframeCacheKey);
      if (cachedTimeframeStr != null) {
        _selectedTimeframe = Duration(days: int.parse(cachedTimeframeStr));
      }

      // Load cached historical data
      final cachedData = _storageService.loadMap(_historicalDataCacheKey);
      if (cachedData != null && cachedData.isNotEmpty) {
        _historicalData = cachedData;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cached data: $e');
      }
    }
  }

  Future<void> _saveCachedData() async {
    try {
      // Save timeframe
      await _storageService.saveString(_timeframeCacheKey, _selectedTimeframe.inDays.toString());
      // Save historical data
      if (_historicalData.isNotEmpty) {
        await _storageService.saveMap(_historicalDataCacheKey, _historicalData);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving cached data: $e');
      }
    }
  }

  Future<void> _loadSavedData() async {
    final savedSnapshots = _storageService.loadPortfolioHistory();
    if (savedSnapshots.isNotEmpty) {
      _snapshots.clear();
      _snapshots.addAll(savedSnapshots);
      notifyListeners();
    }
  }

  String _getTimeframeString() {
    if (_selectedTimeframe.inDays <= 1) return 'daily';
    if (_selectedTimeframe.inDays <= 7) return 'weekly';
    if (_selectedTimeframe.inDays <= 30) return 'monthly';
    return 'monthly';
  }

  Future<void> loadHistoricalData(CurrencySettingsProvider settingsProvider) async {
    String timeframe = _getTimeframeString();
    
    // Only fetch data for symbols that have holdings
    List<String> symbolsWithHoldings = settingsProvider.currencies
        .where((c) => c.isEnabled && (double.tryParse(c.cryptoAmount) ?? 0) > 0)
        .map((c) => c.symbol)
        .toList();

    if (symbolsWithHoldings.isEmpty) return;

    try {
      final data = await _historicalService.getHistoricalData(
        timeframe,
        symbols: symbolsWithHoldings.join(','),
      );
      _historicalData = data;
      // Save to cache after successful fetch
      await _saveCachedData();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading historical data: $e');
      }
      // If we have cached data, keep using it
      if (_historicalData.isEmpty) {
        await _loadCachedData();
      }
    }
  }

  void setTimeframe(Duration timeframe) {
    if (_selectedTimeframe != timeframe) {
      _selectedTimeframe = timeframe;
      _saveCachedData(); // Save timeframe preference
      if (_lastSettingsProvider != null) {
        loadHistoricalData(_lastSettingsProvider!);
      }
    }
  }

  List<PortfolioSnapshot> getHistoricalSnapshots(CurrencySettingsProvider settingsProvider) {
    if (_historicalData.isEmpty) return [];

    List<PortfolioSnapshot> historicalSnapshots = [];
    final rates = _historicalData['rates'] as Map<String, dynamic>?;
    final timestamps = _historicalData['timestamps'] as List<dynamic>?;

    if (rates == null || timestamps == null) return [];

    for (String timestamp in timestamps) {
      double totalValue = 0.0;
      
      for (var currency in settingsProvider.currencies.where((c) => c.isEnabled)) {
        final cryptoAmount = double.tryParse(currency.cryptoAmount) ?? 0.0;
        if (cryptoAmount > 0) {
          final rate = rates[currency.symbol]?[timestamp] ?? 0.0;
          totalValue += cryptoAmount * rate;
        }
      }

      historicalSnapshots.add(PortfolioSnapshot(
        timestamp: DateTime.parse(timestamp),
        value: totalValue,
      ));
    }

    return historicalSnapshots..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  double getCurrentChangePercentage() {
    if (_lastSettingsProvider == null) return 0.0;
    final snapshots = getHistoricalSnapshots(_lastSettingsProvider!);
    if (snapshots.isEmpty) return 0.0;
    
    final currentValue = snapshots.last.value;
    final oldValue = snapshots.first.value;
    
    if (oldValue == 0) return 0.0;
    return ((currentValue - oldValue) / oldValue) * 100;
  }

  double getCurrentChangeAmount() {
    if (_lastSettingsProvider == null) return 0.0;
    final snapshots = getHistoricalSnapshots(_lastSettingsProvider!);
    if (snapshots.isEmpty) return 0.0;
    
    final currentValue = snapshots.last.value;
    final oldValue = snapshots.first.value;
    
    return currentValue - oldValue;
  }

  double getChangePercentageForCrypto(String symbol, Duration timeframe) {
    if (_historicalData.isEmpty) return 0.0;
    
    final rates = _historicalData['rates'] as Map<String, dynamic>?;
    final timestamps = _historicalData['timestamps'] as List<dynamic>?;
    
    if (rates == null || timestamps == null || timestamps.isEmpty) return 0.0;
    
    final symbolRates = rates[symbol] as Map<String, dynamic>?;
    if (symbolRates == null) return 0.0;
    
    final currentRate = symbolRates[timestamps.last] as num?;
    final oldRate = symbolRates[timestamps.first] as num?;
    
    if (currentRate == null || oldRate == null || oldRate == 0) return 0.0;
    
    return ((currentRate - oldRate) / oldRate) * 100;
  }

  void updateLastSettingsProvider(CurrencySettingsProvider provider) {
    _lastSettingsProvider = provider;
  }

  Future<void> onRefresh(CurrencySettingsProvider settingsProvider, CryptoPriceProvider priceProvider) async {
    updateLastSettingsProvider(settingsProvider);
    await loadHistoricalData(settingsProvider);
  }
} 