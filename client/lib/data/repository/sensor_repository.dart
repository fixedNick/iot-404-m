// data/repository/sensor_repository.dart
import 'package:grpc/grpc.dart';
import '../../domain/models/sensor_models.dart';
import '../../generated/iot404/service.pbgrpc.dart' as pb;
// Предполагаем, что GrpcConfig лежит в корне или соседней папке, скорректируйте путь:
import '../../core/grpc_config.dart';

class SensorRepository {
  final ClientChannel _channel;
  final pb.ESP8266ServiceClient _grpcClient;

  // Приватный конструктор для правильного переиспользования одного канала
  SensorRepository._(this._channel)
    : _grpcClient = pb.ESP8266ServiceClient(_channel);

  // Публичная фабрика — инициализирует канал ровно ОДИН раз
  factory SensorRepository() {
    final channel = ClientChannel(
      GrpcConfig.host,
      port: GrpcConfig.port,
      options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectionTimeout: Duration(seconds: GrpcConfig.timeout),
        idleTimeout: const Duration(minutes: 5), // Защита от PROTOCOL_ERROR
      ),
    );
    return SensorRepository._(channel);
  }

  /// Получение статистики. Типы `pb.SensorType` и `pb.PeriodType` берутся напрямую из Protobuf.
  Future<SensorStatsResult> fetchStats({
    required pb.SensorType sensor,
    required pb.PeriodType period,
    required int offset,
  }) async {
    try {
      // 1. Сборка запроса
      final request = pb.GetSensorStatsRequest()
        ..sensor = sensor
        ..period = period
        ..periodOffset = offset
            .abs(); // Инвертируем в положительное число для Go бэкенда

      // 2. Сетевой gRPC запрос с таймаутом из вашего конфига
      final response = await _grpcClient.getSensorStats(
        request,
        options: CallOptions(timeout: Duration(seconds: GrpcConfig.timeout)),
      );

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
      // Перенаправляем ошибку в UI слой для корректного отображения ErrorCard
      rethrow;
    }
  }

  // Очистка ресурсов при закрытии шторки StatsSheet
  Future<void> dispose() async {
    await _channel.shutdown();
  }
}
