import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_settings_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/crypto_price_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151018),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151018),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Currency Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Consumer<CurrencySettingsProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  itemCount: provider.currencies.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final currency = provider.currencies[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: currency.iconColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      currency.icon,
                                      width: 20,
                                      height: 20,
                                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currency.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        currency.symbol,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: currency.isEnabled,
                                  onChanged: (value) {
                                    provider.updateCurrencyEnabled(currency.symbol, value);
                                  },
                                  activeColor: const Color(0xFFBBB0FF),
                                ),
                              ],
                            ),
                            if (currency.isEnabled) ...[
                              const SizedBox(height: 16),
                              // Crypto Amount Input
                              TextField(
                                controller: TextEditingController(text: currency.cryptoAmount),
                                onChanged: (value) {
                                  provider.updateCurrencyAmount(
                                    currency.symbol,
                                    cryptoAmount: value,
                                    priceProvider: Provider.of<CryptoPriceProvider>(context, listen: false),
                                  );
                                },
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Amount in ${currency.symbol}',
                                  labelStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  suffixText: currency.symbol,
                                  suffixStyle: const TextStyle(color: Colors.white),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFBBB0FF),
                                    ),
                                  ),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                              const SizedBox(height: 16),
                              // Euro Amount Input
                              TextField(
                                controller: TextEditingController(text: currency.amount),
                                onChanged: (value) {
                                  provider.updateCurrencyAmount(
                                    currency.symbol,
                                    amount: value,
                                    priceProvider: Provider.of<CryptoPriceProvider>(context, listen: false),
                                  );
                                },
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Amount in EUR',
                                  labelStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  prefixText: '€ ',
                                  prefixStyle: const TextStyle(color: Colors.white),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFBBB0FF),
                                    ),
                                  ),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}