class CryptoPriceData {
  final String symbol;
  final double price;
  final double change24h;

  CryptoPriceData({
    required this.symbol,
    required this.price,
    required this.change24h,
  });

  factory CryptoPriceData.fromJson(Map<String, dynamic> json) {
    return CryptoPriceData(
      symbol: json['symbol'].toString(),
      price: (json['price'] as num).toDouble(),
      change24h: (json['change24h'] as num).toDouble(),
    );
  }
}

class MarketDataResponse {
  final String timestamp;
  final List<CryptoPriceData> data;

  MarketDataResponse({
    required this.timestamp,
    required this.data,
  });

  factory MarketDataResponse.fromJson(Map<String, dynamic> json) {
    return MarketDataResponse(
      timestamp: json['timestamp'].toString(),
      data: (json['data'] as List)
          .map((item) => CryptoPriceData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
} 