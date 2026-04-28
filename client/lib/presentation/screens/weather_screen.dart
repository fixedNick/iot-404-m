import 'package:flutter/material.dart';

import '../../data/repository/wind_repository.dart';
import '../../data/repository/temp_repository.dart';
import '../../data/repository/humidity_repository.dart';

import '../../data/datasource/wind_remote.dart';
import '../../data/datasource/temp_remote.dart';
import '../../data/datasource/humidity_remote.dart';

import '../../domain/models/wind_reading.dart';
import '../../domain/models/temp_reading.dart';
import '../../domain/models/humidity_reading.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late final WindRepository windRepo;
  late final TempRepository tempRepo;
  late final HumidityRepository humidityRepo;

  WindReading? wind;
  TempReading? temp;
  HumidityReading? humidity;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    windRepo = WindRepository(WindRemoteDataSource());

    tempRepo = TempRepository(TempRemoteDataSource());

    humidityRepo = HumidityRepository(HumidityRemoteDataSource());

    refreshData();
  }

  Future<void> refreshData() async {
    setState(() {
      loading = true;
    });

    try {
      final w = await windRepo.fetchWind();
      final t = await tempRepo.fetchTemp();
      final h = await humidityRepo.fetchHumidity();

      setState(() {
        wind = w;
        temp = t;
        humidity = h;
      });
    } catch (e) {
      debugPrint("GRPC error: $e");
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Widget metricCard({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 7),
        padding: const EdgeInsets.symmetric(vertical: 26),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(.10)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),

            const SizedBox(height: 18),

            Text(
              value,
              style: const TextStyle(
                fontFamily: 'AppleSanFrancisco',
                fontWeight: FontWeight.w600,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpg'),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),

          /// overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black26, Colors.black45],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 42),

                  Row(
                    children: [
                      metricCard(
                        icon: Icons.air,
                        value: wind == null
                            ? '--'
                            : '${wind!.speed.toStringAsFixed(1)}',
                        color: Colors.cyanAccent,
                      ),

                      metricCard(
                        icon: Icons.thermostat,
                        value: temp == null
                            ? '--'
                            : '${temp!.temperature.toStringAsFixed(1)}°',
                        color: Colors.orangeAccent,
                      ),

                      metricCard(
                        icon: Icons.water_drop,
                        value: humidity == null
                            ? '--'
                            : '${humidity!.humidity.toStringAsFixed(0)}%',
                        color: Colors.lightBlueAccent,
                      ),
                    ],
                  ),

                  const Spacer(),

                  /// refresh button
                  Center(
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: loading ? null : refreshData,

                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.white.withAlpha(55),
                          foregroundColor: Colors.green.shade400,
                          padding: EdgeInsets.zero,
                          elevation: 10,
                        ),

                        child: loading
                            ? const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              )
                            : const Icon(Icons.refresh, size: 38),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// smaller statistics button
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .72,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        /// navigation later
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      child: const Text(
                        'Статистика',
                        style: TextStyle(
                          fontFamily: 'AppleSanFrancisco',
                          fontWeight: FontWeight.w600,
                          fontSize: 19,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
