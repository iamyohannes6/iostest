import 'dart:convert';
import 'package:http/http.dart' as http;

class HistoricalPriceService {
  static const String baseUrl = 'http://localhost:8080/api';

  Future<Map<String, dynamic>> getHistoricalData(String timeframe, {String? symbols}) async {
    try {
      final uri = Uri.parse('$baseUrl/historical-rates/$timeframe').replace(
        queryParameters: symbols != null ? {'symbols': symbols} : null,
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load historical data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load historical data: $e');
    }
  }

  Future<Map<String, dynamic>> refreshHistoricalData(String timeframe, {String? symbols}) async {
    try {
      final uri = Uri.parse('$baseUrl/historical-rates/$timeframe/refresh').replace(
        queryParameters: symbols != null ? {'symbols': symbols} : null,
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to refresh historical data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to refresh historical data: $e');
    }
  }
} 