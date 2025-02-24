import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/currency_settings.dart';
import '../providers/crypto_price_provider.dart';
import '../services/storage_service.dart';

class CurrencySettingsProvider with ChangeNotifier {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '€',
    decimalDigits: 2,
  );

  static String formatCurrency(double value) {
    return _currencyFormat.format(value);
  }

  static String formatCurrencyFromString(String value) {
    double? amount = double.tryParse(value);
    return formatCurrency(amount ?? 0.0);
  }

  final List<CurrencySettings> _currencies = [];
  final StorageService _storageService;

  CurrencySettingsProvider(this._storageService) {
    _loadSavedData();
    if (_currencies.isEmpty) {
      _initializeDefaultCurrencies();
    }
  }

  void _loadSavedData() {
    final savedCurrencies = _storageService.loadCurrencySettings();
    if (savedCurrencies.isNotEmpty) {
      _currencies.clear();
      _currencies.addAll(savedCurrencies);
      notifyListeners();
    }
  }

  void _initializeDefaultCurrencies() {
    _currencies.addAll([
      CurrencySettings(
        id: 'btc',
        name: 'Bitcoin',
        symbol: 'BTC',
        icon: 'crypto/btc.svg',
        iconColor: const Color(0xFFF7931A),
      ),
      CurrencySettings(
        id: 'eth',
        name: 'Ethereum',
        symbol: 'ETH',
        icon: 'crypto/eth.svg',
        iconColor: const Color(0xFF2EBCCC),
      ),
      CurrencySettings(
        id: 'usdc',
        name: 'USD Coin',
        symbol: 'USDC',
        icon: 'crypto/usdc.svg',
        iconColor: const Color(0xFF2775CA),
      ),
      CurrencySettings(
        id: 'shib',
        name: 'Shiba Inu',
        symbol: 'SHIB',
        icon: 'crypto/shib.svg',
        iconColor: const Color(0xFF2CC4C2),
      ),
      CurrencySettings(
        id: 'lcx',
        name: 'LCX',
        symbol: 'LCX',
        icon: 'crypto/lcx.svg',
        iconColor: const Color(0xFF2EBDCB),
      ),
      CurrencySettings(
        id: 'doge',
        name: 'Dogecoin',
        symbol: 'DOGE',
        icon: 'crypto/doge.svg',
        iconColor: const Color(0xFF64D096),
      ),
      CurrencySettings(
        id: 'link',
        name: 'Chainlink',
        symbol: 'LINK',
        icon: 'crypto/link.svg',
        iconColor: const Color(0xFF2FADD3),
      ),
      CurrencySettings(
        id: 'sol',
        name: 'Solana',
        symbol: 'SOL',
        icon: 'crypto/sol.svg',
        iconColor: const Color(0xFF000000),
      ),
    ]);
    _saveCurrencySettings();
  }

  void _saveCurrencySettings() {
    _storageService.saveCurrencySettings(_currencies);
  }

  List<CurrencySettings> get currencies => _currencies;

  CurrencySettings? getCurrencyBySymbol(String symbol) {
    try {
      return _currencies.firstWhere((currency) => currency.symbol == symbol);
    } catch (e) {
      return null;
    }
  }

  void updateCurrencyAmount(String symbol, {String? amount, String? cryptoAmount, required CryptoPriceProvider priceProvider}) {
    final currency = getCurrencyBySymbol(symbol);
    if (currency != null) {
      final priceData = priceProvider.getPriceDataForSymbol(symbol);
      if (priceData != null) {
        if (amount != null) {
          // User input EUR amount, calculate crypto amount
          currency.amount = amount;
          double eurAmount = double.tryParse(amount) ?? 0.0;
          double cryptoValue = eurAmount / priceData.price;
          currency.cryptoAmount = cryptoValue.toStringAsFixed(8);
        } else if (cryptoAmount != null) {
          // User input crypto amount, calculate EUR amount
          currency.cryptoAmount = cryptoAmount;
          double crypto = double.tryParse(cryptoAmount) ?? 0.0;
          double eurValue = crypto * priceData.price;
          currency.amount = eurValue.toStringAsFixed(2);
        }
        _saveCurrencySettings();
        notifyListeners();
      }
    }
  }

  void updateCurrencyEnabled(String symbol, bool enabled) {
    final currency = getCurrencyBySymbol(symbol);
    if (currency != null) {
      currency.isEnabled = enabled;
      _saveCurrencySettings();
      notifyListeners();
    }
  }

  double getTotalBalanceInEur() {
    double total = 0.0;
    for (var currency in _currencies) {
      if (currency.isEnabled) {
        double amount = double.tryParse(currency.amount) ?? 0.0;
        total += amount;
      }
    }
    return total;
  }
} 