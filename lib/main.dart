import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/crypto_price_provider.dart';
import 'providers/currency_settings_provider.dart';
import 'providers/portfolio_history_provider.dart';
import 'services/storage_service.dart';
import 'config/environment.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize environment
    const String envName = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'production', // Default to production for App Store
    );
    
    final env = BuildEnvironment.values.firstWhere(
      (e) => e.toString() == 'BuildEnvironment.$envName',
      orElse: () => BuildEnvironment.production,
    );
    
    Environment.initialize(env);
    
    final storageService = await StorageService.init();
    
    runApp(MyApp(storageService: storageService));
  } catch (e) {
    print('Initialization error: $e');
    // Show error UI if needed
    runApp(const MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFF151018),
        body: Center(
          child: Text(
            'Failed to initialize app',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  
  const MyApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CryptoPriceProvider()),
        ChangeNotifierProvider(create: (_) => CurrencySettingsProvider(storageService)),
        ChangeNotifierProvider(
          create: (_) => PortfolioHistoryProvider(storageService),
        ),
      ],
      child: MaterialApp(
        title: 'Crypto Wallet',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: const Color(0xFF131315), // Dark background color
          fontFamily: 'Inter',
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
