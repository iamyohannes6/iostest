import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/crypto_price_data.dart';
import '../services/crypto_price_service.dart';

class CryptoPriceProvider with ChangeNotifier {
  final CryptoPriceService _service = CryptoPriceService();
  MarketDataResponse? _marketData;
  Timer? _refreshTimer;
  bool _isLoading = false;
  String? _error;

  MarketDataResponse? get marketData => _marketData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CryptoPriceProvider() {
    // Initial load
    loadMarketData();
    // Set up periodic refresh every 2 minutes
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      loadMarketData();
    });
  }

  CryptoPriceData? getPriceDataForSymbol(String symbol) {
    return _marketData?.data.firstWhere(
      (data) => data.symbol == symbol,
      orElse: () => CryptoPriceData(
        symbol: symbol,
        price: 0.0,
        change24h: 0.0,
      ),
    );
  }

  double getPriceChangeForSymbol(String symbol) {
    return getPriceDataForSymbol(symbol)?.change24h ?? 0.0;
  }

  Future<void> loadMarketData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _marketData = await _service.getMarketData();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshMarketData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _marketData = await _service.refreshMarketData();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
} 