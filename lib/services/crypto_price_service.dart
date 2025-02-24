import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crypto_price_data.dart';

class CryptoPriceService {
  static const String baseUrl = 'http://localhost:8080/api';
  static const List<String> supportedSymbols = ['BTC', 'ETH', 'USDC', 'SHIB', 'LCX', 'DOGE', 'LINK', 'SOL'];

  Future<MarketDataResponse> getMarketData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/market-data'),
        headers: {
          'Accept': 'application/json',
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