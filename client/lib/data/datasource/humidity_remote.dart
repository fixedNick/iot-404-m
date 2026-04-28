import 'package:grpc/grpc.dart';
import '../../core/grpc_config.dart';
import '../../generated/iot404/service.pbgrpc.dart';

class HumidityRemoteDataSource {
  late final ClientChannel _channel;
  late final ESP8266ServiceClient _client;

  HumidityRemoteDataSource() {
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

  Future<HumidityResponse> getWindRaw() async {
    return await _client.humidity(
      HumidityRequest(),
      options: CallOptions(timeout: Duration(seconds: 15)),
    );
  }

  Future<void> dispose() async {
    await _channel.shutdown();
  }
}
