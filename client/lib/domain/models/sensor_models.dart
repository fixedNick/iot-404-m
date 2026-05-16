// domain/models/sensor_models.dart

class ChartDataPoint {
  final DateTime timestamp;
  final double value;
  ChartDataPoint({required this.timestamp, required this.value});
}

class ChartAggregatedPoint {
  final DateTime date;
  final double min;
  final double max;
  final double avg;
  ChartAggregatedPoint({
    required this.date,
    required this.min,
    required this.max,
    required this.avg,
  });
}

class SensorStatsResult {
  final List<ChartDataPoint> dayData;
  final List<ChartAggregatedPoint> aggregatedData;
  SensorStatsResult({required this.dayData, required this.aggregatedData});
}
