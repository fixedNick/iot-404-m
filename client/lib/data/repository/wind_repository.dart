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
}
