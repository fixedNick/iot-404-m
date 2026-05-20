import '../../domain/models/sensor_models.dart';
import '../../generated/iot404/service.pbgrpc.dart' as pb;
import '../datasource/stats_remote.dart';

class SensorRepository {
  final StatsDataSource remote;
  // Приватный конструктор для правильного переиспользования одного канала
  SensorRepository(this.remote);

  /// Получение статистики. Типы `pb.SensorType` и `pb.PeriodType` берутся напрямую из Protobuf.
  Future<SensorStatsResult> fetchStats({
    required pb.SensorType sensor,
    required pb.PeriodType period,
    required int offset,
  }) async {
    try {
      final response = await remote.getSensorStats(period, sensor, offset);
      // 3. Трансформация Protobuf-ответа в чистые Dart модели для графиков fl_chart
      final dayData = response.dayData
          .map(
            (p) => ChartDataPoint(
              timestamp: p.timestamp.toDateTime().toLocal(),
              value: p.value,
            ),
          )
          .toList();

      final aggregatedData = response.aggregatedData
          .map(
            (p) => ChartAggregatedPoint(
              date: p.date.toDateTime().toLocal(),
              min: p.min,
              max: p.max,
              avg: p.avg,
            ),
          )
          .toList();
      return SensorStatsResult(
        dayData: dayData,
        aggregatedData: aggregatedData,
      );
    } catch (e) {
      print("Error in Repo: $e");
      // Перенаправляем ошибку в UI слой для корректного отображения ErrorCard
      rethrow;
    }
  }
}
