import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crypto_price_data.dart';
import '../config/environment.dart';

class CryptoPriceService {
  static String get baseUrl => Environment.apiUrl;
  static const List<String> supportedSymbols = ['BTC', 'ETH', 'USDC', 'SHIB', 'LCX', 'DOGE', 'LINK', 'SOL'];

  Future<MarketDataResponse> getMarketData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/market-data'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return MarketDataResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load market data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load market data: $e');
    }
  }

  Future<MarketDataResponse> refreshMarketData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/market-data/refresh'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return MarketDataResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to refresh market data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to refresh market data: $e');
    }
  }
} 