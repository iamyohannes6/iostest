import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/crypto_price_provider.dart';
import '../providers/currency_settings_provider.dart';
import '../widgets/crypto_list_item.dart';

List<CryptoListItem> getCryptoAssets(BuildContext context) {
  final settingsProvider = Provider.of<CurrencySettingsProvider>(context);
  final priceProvider = Provider.of<CryptoPriceProvider>(context);
  
  return settingsProvider.currencies.where((currency) => currency.isEnabled).map((currency) {
    final priceData = priceProvider.getPriceDataForSymbol(currency.symbol);
    
    double amount = double.tryParse(currency.amount) ?? 0.0;
    double changePercentage = priceData?.change24h ?? 0.0;
    
    return CryptoListItem(
      icon: Container(
        decoration: BoxDecoration(
          color: currency.iconColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/${currency.icon}',
            width: 10,
            height: 10,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),
      name: currency.name,
      symbol: currency.symbol,
      amount: CurrencySettingsProvider.formatCurrency(amount),
      cryptoAmount: double.tryParse(currency.cryptoAmount)?.toStringAsFixed(2) ?? '0.00',
      changePercentage: changePercentage,
      isPositive: changePercentage >= 0,
    );
  }).toList();
} 