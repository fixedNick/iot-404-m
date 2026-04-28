import '../../domain/models/temp_reading.dart';
import '../datasource/temp_remote.dart';

class TempRepository {
  final TempRemoteDataSource remote;

  TempRepository(this.remote);

  Future<TempReading> fetchTemp() async {
    final dto = await remote.getWindRaw();

    return TempReading(
      temperature: dto.temperature,
      timestamp: DateTime.fromMillisecondsSinceEpoch(dto.time.toInt() * 1000),
    );
  }
}
