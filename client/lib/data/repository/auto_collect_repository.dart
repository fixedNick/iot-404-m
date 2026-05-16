import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:grpc/grpc.dart';
import '../../core/grpc_config.dart';
import '../../generated/iot404/service.pbgrpc.dart';

class AutoCollectRepository {
  late final ClientChannel _channel;
  late final ESP8266ServiceClient _client;

  AutoCollectRepository() {
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
  Future<AutoCollectResponse> startAutoCollect({
    required String sensor,
    required int period,
    required int duration,
  }) async {
    var dto = await _client.autoCollect(
      AutoCollectRequest(
        sensor: sensor,
        period: $fixnum.Int64(period),
        duration: $fixnum.Int64(duration),
      ),
      options: CallOptions(timeout: Duration(seconds: 15)),
    );

    return AutoCollectResponse(success: dto.success);
  }

  Future<StopAutoCollectResponse> stopAutoCollect(String sensor) async {
    var dto = await _client.stopAutoCollect(
      StopAutoCollectRequest(sensor: sensor),
      options: CallOptions(timeout: Duration(seconds: 15)),
    );
    return StopAutoCollectResponse(success: dto.success);
  }

  Future<bool> getSensorStatus(String sensor) async {
    var dto = await _client.getSensorStatus(
      GetSensorStatusRequest(sensor: sensor),
      options: CallOptions(timeout: Duration(seconds: 15)),
    );

    return dto.enabled;
  }
}
