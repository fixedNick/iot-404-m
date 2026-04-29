import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
      final results = await Future.wait([
        windRepo.fetchWind(),
        tempRepo.fetchTemp(),
        humidityRepo.fetchHumidity(),
      ]);

      final w = results[0];
      final t = results[1];
      final h = results[2];

      setState(() {
        wind = w as WindReading;
        temp = t as TempReading;
        humidity = h as HumidityReading;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(.25),
                  Colors.black.withOpacity(.65),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  /// top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Дивноморское",
                        style: TextStyle(
                          fontFamily: "AppleSanFrancisco",
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),

                      _glassIcon(Icons.settings, () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const AutoCollectSheet(),
                        );
                      }),
                    ],
                  ),

                  /// hero temp
                  Text(
                    temp == null
                        ? "22"
                        : "${temp!.temperature.toStringAsFixed(1)}°",
                    style: const TextStyle(
                      fontFamily: "AppleSanFrancisco",
                      fontSize: 72,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      sensorCard(
                        Icons.air,
                        wind == null ? "--" : wind!.speed.toStringAsFixed(1),
                        Colors.cyanAccent,
                      ),

                      sensorCard(
                        Icons.thermostat,
                        temp == null
                            ? "--"
                            : "${temp!.temperature.toStringAsFixed(1)}°",
                        Colors.orangeAccent,
                      ),

                      sensorCard(
                        Icons.water_drop,
                        humidity == null
                            ? "--"
                            : "${humidity!.humidity.toStringAsFixed(0)}%",
                        Colors.blueAccent,
                      ),
                    ],
                  ),

                  const Spacer(),

                  _glassIcon(
                    Icons.refresh,
                    refreshData,
                    loading: loading,
                    size: 70,
                  ),

                  const SizedBox(height: 30),

                  /// statistics button
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => const StatsSheet(),
                      );
                    },

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),

                        color: Colors.white.withOpacity(.14),

                        border: Border.all(color: Colors.white24),
                      ),

                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.show_chart, color: Colors.white),

                          SizedBox(width: 12),

                          Text(
                            "Статистика",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sensorCard(IconData icon, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),

        padding: const EdgeInsets.symmetric(vertical: 30),

        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.13),

          borderRadius: BorderRadius.circular(30),

          border: Border.all(color: Colors.white24),
        ),

        child: Column(
          children: [
            Icon(icon, size: 25, color: color),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: "AppleSanFrancisco",
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassIcon(
    IconData icon,
    VoidCallback onTap, {
    bool loading = false,
    double size = 58,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,

        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(.15),
          border: Border.all(color: Colors.white24),
        ),

        child: Center(
          child: loading
              ? const CircularProgressIndicator()
              : Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

class AutoCollectSheet extends StatefulWidget {
  const AutoCollectSheet({super.key});

  @override
  State<AutoCollectSheet> createState() => _AutoCollectSheetState();
}

class _AutoCollectSheetState extends State<AutoCollectSheet> {
  String sensor = 'temperature';

  bool infinite = false;

  final durationController = TextEditingController();

  final periodController = TextEditingController(text: "1000");

  @override
  Widget build(context) {
    return Container(
      padding: EdgeInsets.only(
        left: 25,
        right: 25,
        top: 30,
        bottom: MediaQuery.of(context).viewInsets.bottom + 30,
      ),

      decoration: BoxDecoration(
        color: Color(0xff1b1f29),
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Авто сбор",
            style: TextStyle(color: Colors.white, fontSize: 28),
          ),

          SizedBox(height: 25),

          DropdownButtonFormField(
            style: TextStyle(color: Colors.white),
            dropdownColor: const Color.fromARGB(255, 29, 29, 29),
            initialValue: sensor,
            focusColor: Colors.white,
            items: [
              DropdownMenuItem(value: "wind", child: Text("Ветер")),

              DropdownMenuItem(
                value: "temperature",
                child: Text("Температура"),
              ),

              DropdownMenuItem(value: "humidity", child: Text("Влажность")),
            ],
            onChanged: (v) {
              setState(() => sensor = v!);
            },
          ),

          SizedBox(height: 20),

          TextField(
            style: TextStyle(color: Colors.white),
            controller: durationController,
            enabled: !infinite,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Продолжительность",
              labelStyle: TextStyle(color: Colors.white),
              floatingLabelStyle: TextStyle(color: Colors.blue.shade100),
            ),
          ),

          Row(
            children: [
              Checkbox(
                value: infinite,
                onChanged: (v) {
                  setState(() => infinite = v!);
                },
              ),

              Icon(Icons.all_inclusive, color: Colors.white),

              SizedBox(width: 10),

              Text("Бесконечно", style: TextStyle(color: Colors.white)),
            ],
          ),

          SizedBox(height: 20),

          TextField(
            controller: periodController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Colors.white),

            decoration: InputDecoration(
              labelText: "Периодичность",
              hintStyle: TextStyle(color: Colors.white),
              labelStyle: TextStyle(color: Colors.white),
              floatingLabelStyle: TextStyle(color: Colors.blue.shade100),
            ),
          ),

          SizedBox(height: 30),

          ElevatedButton.icon(
            icon: Icon(Icons.play_arrow),

            label: Text("Запустить"),

            onPressed: () {
              final period = int.tryParse(periodController.text) ?? 1000;

              if (period < 1000) {
                return;
              }

              final duration = infinite
                  ? 0
                  : int.tryParse(durationController.text) ?? 0;

              /// grpc
              /*
      grpc.startAutoCollection(
        sensor:sensor,
        duration:duration,
        period:period,
      );
      */
              /* TODO использовать для запуска авто
await grpc.startAutoCollection(...);

widget.onRefresh?.call();

Navigator.pop(context);
      */
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class StatsSheet extends StatelessWidget {
  const StatsSheet({super.key});

  @override
  Widget build(context) {
    return Container(
      height: 400,

      decoration: BoxDecoration(
        color: Color(0xff171c25),

        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),

      child: Column(
        children: [
          SizedBox(height: 25),

          Text(
            "Температура",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),

          SizedBox(height: 20),

          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,

                    spots: [
                      FlSpot(1, 18),
                      FlSpot(2, 21),
                      FlSpot(3, 20),
                      FlSpot(4, 24),
                      FlSpot(5, 22),
                      FlSpot(6, 25),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
