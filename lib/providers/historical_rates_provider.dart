import 'package:flutter/foundation.dart';
import '../models/historical_rates.dart';

class HistoricalRatesProvider with ChangeNotifier {
  HistoricalRates? _currentRates;
  final String _currentTimeframe = 'daily';
  bool _isLoading = false;
  String? _error;

  HistoricalRates? get currentRates => _currentRates;
  String get currentTimeframe => _currentTimeframe;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Map UI timeframe to API timeframe
  String _mapTimeframe(String timeframe) {
    switch (timeframe.toLowerCase()) {
      case '1d':
        return 'daily';
      case '1w':
        return 'weekly';
      case '1m':
        return 'monthly';
      case '1y':
        return 'yearly';
      default:
        return 'daily';
    }
  }

  Future<void> fetchHistoricalRates(String timeframe) async {
    final apiTimeframe = _mapTimeframe(timeframe);
    if (_currentTimeframe == apiTimeframe && _currentRates != null) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  Future<void> refreshHistoricalRates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

  }

  List<double>? getRatesForSymbol(String symbol) {
    return _currentRates?.getRatesForSymbol(symbol);
  }

  List<String> get timestamps => _currentRates?.timestamps ?? [];
} 