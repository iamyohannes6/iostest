class PortfolioSnapshot {
  final DateTime timestamp;
  final double value;

  PortfolioSnapshot({
    required this.timestamp,
    required this.value,
  });

  factory PortfolioSnapshot.fromJson(Map<String, dynamic> json) {
    return PortfolioSnapshot(
      timestamp: DateTime.parse(json['timestamp']),
      value: json['value'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'value': value,
  };
}

class PortfolioHistory {
  final List<PortfolioSnapshot> snapshots;

  PortfolioHistory({
    required this.snapshots,
  });

  double getChangePercentage(Duration timeframe) {
    if (snapshots.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final targetTime = now.subtract(timeframe);
    
    // Get current value
    final currentSnapshot = snapshots.last;
    
    // Find closest snapshot to target time
    PortfolioSnapshot? pastSnapshot;
    for (var snapshot in snapshots.reversed) {
      if (snapshot.timestamp.isBefore(targetTime)) {
        pastSnapshot = snapshot;
        break;
      }
    }
    
    if (pastSnapshot == null) return 0.0;
    
    if (pastSnapshot.value == 0) return 0.0;
    
    return ((currentSnapshot.value - pastSnapshot.value) / 
            pastSnapshot.value) * 100;
  }

  double getChangeAmount(Duration timeframe) {
    if (snapshots.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final targetTime = now.subtract(timeframe);
    
    // Get current value
    final currentSnapshot = snapshots.last;
    
    // Find closest snapshot to target time
    PortfolioSnapshot? pastSnapshot;
    for (var snapshot in snapshots.reversed) {
      if (snapshot.timestamp.isBefore(targetTime)) {
        pastSnapshot = snapshot;
        break;
      }
    }
    
    if (pastSnapshot == null) return 0.0;
    
    return currentSnapshot.value - pastSnapshot.value;
  }
} 