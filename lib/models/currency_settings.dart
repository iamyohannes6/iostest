import 'dart:ui';

class CurrencySettings {
  final String id;
  final String name;
  final String symbol;
  final String icon;
  final Color iconColor;
  bool isEnabled;
  String amount;      // Amount in EUR
  String cryptoAmount; // Amount in crypto units

  CurrencySettings({
    required this.id,
    required this.name,
    required this.symbol,
    required this.icon,
    required this.iconColor,
    this.isEnabled = true,
    this.amount = '0.00',
    this.cryptoAmount = '0.0000000',
  });
}