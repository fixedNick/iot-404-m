import 'package:grpc/grpc.dart';
import '../../core/grpc_config.dart';
import '../../generated/iot404/service.pbgrpc.dart';

class WindRemoteDataSource {
  late final ClientChannel _channel;
  late final ESP8266ServiceClient _client;

  WindRemoteDataSource() {
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

  Future<WindSpeedResponse> getWindRaw() async {
    return await _client.windSpeed(
      WindSpeedRequest(),
      options: CallOptions(timeout: Duration(seconds: 15)),
    );
  }

  Future<void> dispose() async {
    await _channel.shutdown();
  }
}
