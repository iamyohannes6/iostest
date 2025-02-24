import 'package:flutter/cupertino.dart'; // Import Cupertino widgets
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/crypto_assets.dart';  // Add this import
import '../providers/crypto_price_provider.dart';
import '../providers/currency_settings_provider.dart';
import '../providers/portfolio_history_provider.dart';

class AllAssetsScreen extends StatefulWidget {
  const AllAssetsScreen({super.key});

  @override
  _AllAssetsScreenState createState() => _AllAssetsScreenState();
}

class _AllAssetsScreenState extends State<AllAssetsScreen> {
  bool _isRefreshing = false;

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    final priceProvider = Provider.of<CryptoPriceProvider>(context, listen: false);
    final settingsProvider = Provider.of<CurrencySettingsProvider>(context, listen: false);
    final historyProvider = Provider.of<PortfolioHistoryProvider>(context, listen: false);
    
    // Refresh market data
    await priceProvider.refreshMarketData();
    
    // Update history with new refresh point
    historyProvider.onRefresh(settingsProvider, priceProvider);
    
    // Wait for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });
  }

  Widget _buildCryptoList(BuildContext context) {
    final priceProvider = Provider.of<CryptoPriceProvider>(context); // Listen to provider
    
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
        top: 5,
      ),
      child: Column(
        children: [
          if (priceProvider.error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Error: ${priceProvider.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ...getCryptoAssets(context),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 65),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 25,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Add assets',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151018),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151018),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.white, size: 35),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CupertinoTheme(
        data: CupertinoThemeData(
          primaryColor: const Color(0xFF8C81DD), // Customize the refresh indicator color
        ),
        child: CustomScrollView(
          physics: _isRefreshing
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: _onRefresh,
              refreshTriggerPullDistance: 100.0,
              refreshIndicatorExtent: 60.0,
              builder: (
                BuildContext context,
                RefreshIndicatorMode refreshState,
                double pulledExtent,
                double refreshTriggerPullDistance,
                double refreshIndicatorExtent,
              ) {
                return Center(
                  child: CupertinoActivityIndicator(
                    color: const Color(0xFF715AB9),
                    radius: 14.0,
                  ),
                );
              },
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Assets',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _buildCryptoList(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}