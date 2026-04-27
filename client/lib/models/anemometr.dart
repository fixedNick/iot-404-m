import 'package:grpc/grpc.dart';
import 'package:client/generated/iot404/service.pbgrpc.dart';

class WindData {
  final double? speed;
  final double? voltage;
  final DateTime? timestamp;
  final String? message;
  WindData({this.speed, this.voltage, this.timestamp, this.message});
}

// Репозиторий (Сервис)
class AnemometerRepository {
  static ESP8266ServiceClient? _client;
  ESP8266ServiceClient _getClient() {
    if (_client != null) return _client!;

    final channel = ClientChannel(
      '176.109.106.237', // IP твоего устройства или сервера
      port: 50051,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(), // Для локалки без SSL
        connectTimeout: Duration(seconds: 5),
      ),
    );

    _client = ESP8266ServiceClient(channel);
    return _client!;
  }

  Future<WindData> fetchCurrentWeather() async {
    final client = _getClient();
    try {
      final response = await client.windSpeed(WindSpeedRequest());
      return WindData(
        speed: response.speed,
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          response.time.toInt() * 1000,
        ),
        voltage: response.voltage,
      );
    } catch (e) {
      return WindData(message: e.toString());
    }
  }
}
