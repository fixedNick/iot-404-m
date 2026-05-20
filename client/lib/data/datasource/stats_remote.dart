import 'package:grpc/grpc.dart';
import '../../core/grpc_config.dart';
import '../../generated/iot404/service.pbgrpc.dart';

class StatsDataSource {
  late final ClientChannel _channel;
  late final ESP8266ServiceClient _client;

  StatsDataSource() {
    _channel = ClientChannel(
      GrpcConfig.host,
      port: GrpcConfig.port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectTimeout: Duration(seconds: GrpcConfig.timeout),
      ),
    );

    _client = ESP8266ServiceClient(_channel);
  }

  Future<GetSensorStatsResponse> getSensorStats(
    PeriodType p,
    SensorType sens,
    int periodOffset,
  ) async {
    return await _client.getSensorStats(
      GetSensorStatsRequest(
        sensor: sens,
        period: p,
        periodOffset: periodOffset,
      ),
      options: CallOptions(timeout: Duration(seconds: GrpcConfig.timeout)),
    );
  }

  Future<void> dispose() async {
    await _channel.shutdown();
  }
}
