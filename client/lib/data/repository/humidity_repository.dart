import '../../domain/models/humidity_reading.dart';
import '../datasource/humidity_remote.dart';

class HumidityRepository {
  final HumidityRemoteDataSource remote;

  HumidityRepository(this.remote);

  Future<HumidityReading> fetchHumidity() async {
    final dto = await remote.getWindRaw();

    return HumidityReading(
      humidity: dto.humidity,
      timestamp: DateTime.fromMillisecondsSinceEpoch(dto.time.toInt() * 1000),
    );
  }
}
