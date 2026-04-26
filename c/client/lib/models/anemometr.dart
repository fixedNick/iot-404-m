import 'package:grpc/grpc.dart';
import 'package:client/generated/iot404/service.pbgrpc.dart';
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart'; // Путь к твоим файлам

class WindData {
  final double speed;
  final DateTime timestamp;
  final int status;
  final String? message;

  WindData({
    required this.speed,
    required this.timestamp,
    required this.status,
    this.message,
  });
}

// Репозиторий (Сервис)
class AnemometerRepository {
  static ESP8266Client? _client;
  ESP8266Client _getClient() {
    if (_client != null) return _client!;

    final channel = ClientChannel(
      '176.109.106.237', // IP твоего устройства или сервера
      port: 50051,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(), // Для локалки без SSL
        connectTimeout: Duration(seconds: 5),
      ),
    );

    _client = ESP8266Client(channel);
    return _client!;
  }

  Future<WindData> fetchCurrentWeather() async {
    final client = _getClient();
    try {
      final response = await client.windspeed(Empty());
      if (response.status == 0) {
        return WindData(
          speed: response.speed,
          timestamp: DateTime.now(),
          status: response.status,
        );
      }
      return WindData(
        speed: 0.0,
        timestamp: DateTime.now(),
        status: response.status,
        message: "Ошибка: ${response.message}",
      );
    } catch (e) {
      return WindData(
        speed: 0.0,
        timestamp: DateTime.now(),
        status: -1,
        message: e.toString(),
      );
    }
  }
}
