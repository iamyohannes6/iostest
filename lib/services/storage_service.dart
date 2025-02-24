import 'dart:convert';
import 'package:flutter/material.dart' show Color;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/portfolio_history.dart';
import '../models/currency_settings.dart';

class StorageService {
  static const String _portfolioKey = 'portfolio_history';
  static const String _currencySettingsKey = 'currency_settings';
  
  final SharedPreferences _prefs;
  
  StorageService(this._prefs);
  
  // Initialize SharedPreferences
  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Save string value
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  // Load string value
  String? loadString(String key) {
    return _prefs.getString(key);
  }

  // Save map value
  Future<void> saveMap(String key, Map<String, dynamic> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  // Load map value
  Map<String, dynamic>? loadMap(String key) {
    final data = _prefs.getString(key);
    if (data != null) {
      try {
        return jsonDecode(data) as Map<String, dynamic>;
      } catch (e) {
        print('Error decoding cached map data: $e');
      }
    }
    return null;
  }

  // Save portfolio history
  Future<void> savePortfolioHistory(List<PortfolioSnapshot> snapshots) async {
    final List<Map<String, dynamic>> data = snapshots.map((snapshot) => {
      'timestamp': snapshot.timestamp.toIso8601String(),
      'value': snapshot.value,
    }).toList();
    
    await _prefs.setString(_portfolioKey, jsonEncode(data));
  }

  // Load portfolio history
  List<PortfolioSnapshot> loadPortfolioHistory() {
    final String? data = _prefs.getString(_portfolioKey);
    if (data == null) return [];

    try {
      final List<dynamic> jsonData = jsonDecode(data);
      return jsonData.map((item) => PortfolioSnapshot(
        timestamp: DateTime.parse(item['timestamp']),
        value: (item['value'] as num).toDouble(),
      )).toList();
    } catch (e) {
      print('Error loading portfolio history: $e');
      return [];
    }
  }

  // Save currency settings
  Future<void> saveCurrencySettings(List<CurrencySettings> currencies) async {
    final List<Map<String, dynamic>> data = currencies.map((currency) => {
      'id': currency.id,
      'name': currency.name,
      'symbol': currency.symbol,
      'icon': currency.icon,
      'iconColor': currency.iconColor.value,
      'isEnabled': currency.isEnabled,
      'amount': currency.amount,
      'cryptoAmount': currency.cryptoAmount,
    }).toList();
    
    await _prefs.setString(_currencySettingsKey, jsonEncode(data));
  }

  // Load currency settings
  List<CurrencySettings> loadCurrencySettings() {
    final String? data = _prefs.getString(_currencySettingsKey);
    if (data == null) return [];

    try {
      final List<dynamic> jsonData = jsonDecode(data);
      return jsonData.map((item) => CurrencySettings(
        id: item['id'],
        name: item['name'],
        symbol: item['symbol'],
        icon: item['icon'],
        iconColor: Color(item['iconColor']),
        isEnabled: item['isEnabled'],
        amount: item['amount'],
        cryptoAmount: item['cryptoAmount'],
      )).toList();
    } catch (e) {
      print('Error loading currency settings: $e');
      return [];
    }
  }

  // Clear all stored data
  Future<void> clearAllData() async {
    await _prefs.clear();
  }
} 