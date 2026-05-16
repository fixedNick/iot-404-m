import '../../domain/models/wind_reading.dart';
import '../datasource/wind_remote.dart';

class WindRepository {
  final WindRemoteDataSource remote;

  WindRepository(this.remote);

  Future<WindReading> fetchWind() async {
    final dto = await remote.getWindRaw();

    return WindReading(
      voltage: dto.voltage,
      speed: dto.speed,
      timestamp: DateTime.fromMillisecondsSinceEpoch(dto.time.toInt() * 1000),
    );
  }

  Future<List<SensorPoint>> getWindStats(DateTime from, DateTime to) async {
    return [
      // SensorPoint(DateTime(2026, 5, 1, 3, 15, 36), 3.22),
      // SensorPoint(DateTime(2026, 5, 1, 5, 15, 36), 7.22),
      // SensorPoint(DateTime(2026, 5, 1, 7, 15, 36), 11.22),
      // SensorPoint(DateTime(2026, 5, 1, 9, 15, 36), 15.22),
      // SensorPoint(DateTime(2026, 5, 1, 12, 15, 36), 12.22),
      // SensorPoint(DateTime(2026, 5, 1, 14, 15, 36), 17.22),
      // SensorPoint(DateTime(2026, 5, 1, 16, 15, 36), 15.22),
      // SensorPoint(DateTime(2026, 5, 1, 18, 15, 36), 16.22),
      // SensorPoint(DateTime(2026, 5, 1, 20, 15, 36), 10.22),
      // SensorPoint(DateTime(2026, 5, 1, 22, 15, 36), 8.22),
      SensorPoint(DateTime(2026, 5, 1, 23, 15, 36), 5.22),

      SensorPoint(DateTime(2026, 5, 2, 12, 15, 36), 10.22),
      SensorPoint(DateTime(2026, 5, 3, 12, 15, 36), 17.22),
      SensorPoint(DateTime(2026, 5, 4, 12, 15, 36), 13.22),
      SensorPoint(DateTime(2026, 5, 5, 12, 15, 36), 14.22),
      SensorPoint(DateTime(2026, 5, 6, 12, 15, 36), 25.22),
      SensorPoint(DateTime(2026, 5, 7, 12, 15, 36), 32.22),
    ];
  }
}

class SensorPoint {
  final DateTime time;
  final double value;

  SensorPoint(this.time, this.value);
}
