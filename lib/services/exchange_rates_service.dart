import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRatesService {
  static const String baseUrl = 'http://localhost:8080/api';

  Future<Map<String, dynamic>> getHistoricalRates(String timeframe) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/historical-rates/$timeframe'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load historical rates: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load historical rates: $e');
    }
  }

  Future<Map<String, dynamic>> refreshHistoricalRates(String timeframe) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/historical-rates/$timeframe/refresh'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to refresh historical rates: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to refresh historical rates: $e');
    }
  }
} 