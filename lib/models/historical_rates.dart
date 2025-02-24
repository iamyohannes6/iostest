class HistoricalRates {
  final bool success;
  final String timeframe;
  final Map<String, Map<String, double>> rates;
  final List<String> timestamps;

  HistoricalRates({
    required this.success,
    required this.timeframe,
    required this.rates,
    required this.timestamps,
  });

  factory HistoricalRates.fromJson(Map<String, dynamic> json) {
    final rates = <String, Map<String, double>>{};
    final timestamps = <String>[];

    // Convert timeseries data
    json['rates'].forEach((timestamp, rateData) {
      timestamps.add(timestamp);
      rateData.forEach((symbol, rate) {
        if (!rates.containsKey(symbol)) {
          rates[symbol] = {};
        }
        rates[symbol]![timestamp] = rate.toDouble();
      });
    });

    return HistoricalRates(
      success: json['success'] ?? false,
      timeframe: json['timeframe'] ?? 'daily',
      rates: rates,
      timestamps: timestamps,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'timeframe': timeframe,
    'rates': rates,
    'timestamps': timestamps,
  };

  double? getRate(String symbol, String timestamp) {
    return rates[symbol]?[timestamp];
  }

  List<double> getRatesForSymbol(String symbol) {
    return timestamps.map((timestamp) => rates[symbol]?[timestamp] ?? 0.0).toList();
  }
} 