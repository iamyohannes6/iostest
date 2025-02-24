import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../widgets/price_chart.dart';
import '../widgets/crypto_list_item.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/crypto_price_provider.dart';
import '../data/crypto_assets.dart';
import 'all_assets_screen.dart';
import 'settings_screen.dart';
import '../providers/currency_settings_provider.dart';
import '../providers/portfolio_history_provider.dart';
import '../models/portfolio_history.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const GradientBackground({
    super.key,
    required this.child,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            backgroundColor.withOpacity(0.4),
            const Color(0xFF151018),
          ],
          stops: const [0.0, 0.30],
        ),
      ),
      child: child,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRefreshing = false;
  bool _hideAmounts = false;
  final ScrollController _scrollController = ScrollController();
  Color _backgroundColor = const Color(0xFF685B92);
  CurrencySettingsProvider? _lastSettingsProvider;
  PortfolioSnapshot? _selectedSnapshot;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Initialize portfolio history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = Provider.of<CurrencySettingsProvider>(context, listen: false);
      final historyProvider = Provider.of<PortfolioHistoryProvider>(context, listen: false);
      historyProvider.initialize(settingsProvider);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final double offset = _scrollController.offset;
    final double maxOffset = _scrollController.position.maxScrollExtent;
    double t = offset / maxOffset;
    t = t * 5.0;

    setState(() {
      _backgroundColor = Color.lerp(
        const Color(0xFF685B92),
        const Color(0xFF151018),
        t.clamp(0.0, 1.0),
      )!;
    });
  }

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
    await historyProvider.onRefresh(settingsProvider, priceProvider);
    
    // Wait for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        backgroundColor: _backgroundColor,
        child: CustomScrollView(
          controller: _scrollController,
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
            SliverSafeArea(
              bottom: false,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(context),
                ]),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                minHeight: 40.0,
                maxHeight: 90.0,
                  child: _buildTabs(),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                _buildBalanceSection(),
                _buildActionButtons(),
                _buildCryptoList(context),
              ]),
            ),
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'Wallet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _hideAmounts = !_hideAmounts;
                  });
                },
                child: Icon(
                  _hideAmounts ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
                  color: Colors.white
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/top_header/card.svg',
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/top_header/wave.svg',
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/top_header/notification.svg',
                  width: 24,
                  height: 24,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/top_header/settings.svg',
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildTab('Crypto', true),
          const SizedBox(width: 12),
          _buildTab('NFTs', false),
          const SizedBox(width: 12),
          _buildTab('Market', false),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF8C81DD)
            : Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBalanceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 52.0),
      child: Consumer3<CurrencySettingsProvider, CryptoPriceProvider, PortfolioHistoryProvider>(
        builder: (context, settingsProvider, priceProvider, historyProvider, _) {
          double totalBalance = _selectedSnapshot?.value ?? settingsProvider.getTotalBalanceInEur();

          historyProvider.updateLastSettingsProvider(settingsProvider);
          _lastSettingsProvider = settingsProvider;

          double changePercentage;
          double changeAmount;

          if (_selectedSnapshot != null) {
            final snapshots = historyProvider.getHistoricalSnapshots(settingsProvider);
            if (snapshots.isNotEmpty) {
              final currentBalance = settingsProvider.getTotalBalanceInEur();
              final selectedValue = _selectedSnapshot!.value;

              changeAmount = currentBalance - selectedValue;
              changePercentage = selectedValue != 0 ? (changeAmount / selectedValue) * 100 : 0;
            } else {
              changeAmount = 0;
              changePercentage = 0;
            }
          } else {
            changePercentage = historyProvider.getCurrentChangePercentage();
            changeAmount = historyProvider.getCurrentChangeAmount();
          }

          bool isPositive = changeAmount >= 0;

          return Column(
            children: [
              Text(
                _hideAmounts ? '€***' : CurrencySettingsProvider.formatCurrency(totalBalance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    isPositive
                        ? 'assets/icons/indicator_arrow_up.svg'
                        : 'assets/icons/indicator_arrow_down.svg',
                    width: 12,
                    height: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${changePercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: isPositive
                          ? const Color(0xFF759a6e)
                          : const Color(0xFFb5646d),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _hideAmounts
                        ? '(€***)'
                        : '(${CurrencySettingsProvider.formatCurrency(double.parse(changeAmount.toStringAsFixed(1)))})', // Format to 1 decimal place
                    style: TextStyle(
                      color: isPositive
                          ? const Color(0xFF759a6e)
                          : const Color(0xFFb5646d),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer2<PortfolioHistoryProvider, CurrencySettingsProvider>(
                builder: (context, historyProvider, settingsProvider, _) {
                  final snapshots = historyProvider.getHistoricalSnapshots(settingsProvider);
                  return PriceChart(
                    snapshots: snapshots,
                    height: 150,
                    lineColor: const Color(0xFFb8b0e5),
                    fillColor: const Color(0x1Ab8b0e5),
                    onPointSelected: (snapshot) {
                      setState(() {
                        _selectedSnapshot = snapshot;
                      });
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Container(
          height: 41,
          margin: const EdgeInsets.symmetric(horizontal: 100),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Consumer<PortfolioHistoryProvider>(
            builder: (context, historyProvider, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeframeButton('1D', const Duration(days: 1), historyProvider),
                  _buildTimeframeButton('1W', const Duration(days: 7), historyProvider),
                  _buildTimeframeButton('1M', const Duration(days: 30), historyProvider),
                  _buildTimeframeButton('1Y', const Duration(days: 365), historyProvider),
                  _buildTimeframeButton('ALL', const Duration(days: 3650), historyProvider),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton('buy.svg', 'Buy', width: 16, height: 16),
              _buildActionButton('swap_small.svg', 'Swap', width: 18, height: 19),
              _buildActionButton('send.svg', 'Send', width: 14, height: 16),
              _buildActionButton('receive.svg', 'Receive', width: 14, height: 16),
              _buildActionButton('earn_small.svg', 'Earn', width: 18, height: 17),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeButton(String text, Duration timeframe, PortfolioHistoryProvider historyProvider) {
    final isSelected = historyProvider.selectedTimeframe == timeframe;
    
    return GestureDetector(
      onTap: () async {
        historyProvider.setTimeframe(timeframe);
        if (_lastSettingsProvider != null) {
          await historyProvider.loadHistoricalData(_lastSettingsProvider!);
        }
      },
      child: Container(
        width: 41,
        height: 41,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(isSelected ? 1 : 0.5),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String iconPath, String label, {double? width, double? height}) {
    return Container(
      width: 72,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2F).withOpacity(0.25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'icons/action_buttons/$iconPath',
                width: width,
                height: height,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCryptoList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
        top: 42,
      ),
      child: Consumer3<CryptoPriceProvider, CurrencySettingsProvider, PortfolioHistoryProvider>(
        builder: (context, priceProvider, settingsProvider, historyProvider, _) {
          final cryptoAssets = getCryptoAssets(context);
          
          return Column(
            children: [
              if (priceProvider.error != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Error: ${priceProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (!priceProvider.isLoading && cryptoAssets.isNotEmpty)
                ...cryptoAssets.take(5).map((asset) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: CryptoListItem(
                    icon: asset.icon,
                    name: asset.name,
                    symbol: asset.symbol,
                    amount: _hideAmounts ? '€***' : asset.amount,
                    cryptoAmount: _hideAmounts ? '***' : asset.cryptoAmount,
                    changePercentage: asset.changePercentage,
                    isPositive: asset.isPositive,
                  ),
                )),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AllAssetsScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 65),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  child: const Text(
                    'See all assets',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 25.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'For You',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
                SizedBox(
                  height: 150,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.5),
                        child: SizedBox(
                          width: 370,
                          height: 150,
                          child: Image.asset(
                              'assets/ad/ad_1.png',
                            fit: BoxFit.fill
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: SizedBox(
                          width: 370,
                          height: 150,
                          child: Image.asset(
                              'assets/ad/ad_2.png',
                            fit: BoxFit.fill
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    double opacity = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    return Container(
      color: Color.lerp(Colors.transparent, Color(0xFF151018), opacity)!,
      child: SizedBox.expand(child: child),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}