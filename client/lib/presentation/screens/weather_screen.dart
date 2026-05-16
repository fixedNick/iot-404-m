import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/repository/wind_repository.dart';
import '../../data/repository/temp_repository.dart';
import '../../data/repository/humidity_repository.dart';
import '../../data/repository/auto_collect_repository.dart';

import '../../data/datasource/wind_remote.dart';
import '../../data/datasource/temp_remote.dart';
import '../../data/datasource/humidity_remote.dart';

import '../../domain/models/wind_reading.dart';
import '../../domain/models/temp_reading.dart';
import '../../domain/models/humidity_reading.dart';

import 'stats_2.dart';

import '../../data/repository/sensor_repository.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  late final WindRepository windRepo;
  late final TempRepository tempRepo;
  late final HumidityRepository humidityRepo;

  WindReading? wind;
  TempReading? temp;
  HumidityReading? humidity;
  bool loading = false;

  late final AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    windRepo = WindRepository(WindRemoteDataSource());
    tempRepo = TempRepository(TempRemoteDataSource());
    humidityRepo = HumidityRepository(HumidityRemoteDataSource());

    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    refreshData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> refreshData() async {
    if (loading) return;
    setState(() => loading = true);
    _refreshController.repeat();

    try {
      final results = await Future.wait([
        windRepo.fetchWind(),
        tempRepo.fetchTemp(),
        humidityRepo.fetchHumidity(),
      ]);

      setState(() {
        wind = results[0] as WindReading;
        temp = results[1] as TempReading;
        humidity = results[2] as HumidityReading;
      });
    } catch (e) {
      debugPrint("GRPC error: $e");
    } finally {
      if (mounted) {
        _refreshController.forward(from: _refreshController.value).then((_) {
          _refreshController.reset();
        });
        setState(() => loading = false);
      }
    }
  }

  String _lastSensorDataTime(int n, WindReading? w) {
    if (w == null) return "--";
    if (n == 0) {
      final mt = DateFormat("MMM", "ru").format(w.timestamp);
      final d = DateFormat("dd", "ru").format(w.timestamp);
      final m = mt.isNotEmpty
          ? mt[0].toUpperCase() + mt.substring(1).toLowerCase()
          : "";
      final y = DateFormat("yyyy", "ru").format(w.timestamp);
      return "$d $m $y";
    }
    return DateFormat("HH:mm:ss", "ru").format(w.timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset("assets/images/bg.jpg", fit: BoxFit.cover),
          ),
          // Apple Styling Subtle Vignette Layer
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.55),
                  ],
                ),
              ),
            ),
          ),
          // Main UI Layer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // Top Action Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Spacer(),
                      _glassIcon(
                        Icons.settings_outlined,
                        () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const AutoCollectSheet(),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 1),
                  // City Name Display
                  const Text(
                    "Дивноморское",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Dynamic Large Hero Temp
                  Text(
                    temp == null
                        ? "22°"
                        : "${temp!.temperature.toStringAsFixed(1)}°",
                    style: const TextStyle(
                      fontSize: 88,
                      fontWeight: FontWeight.w200,
                      letterSpacing: -2.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Horizontal Grid Sensor Metrics
                  Row(
                    children: [
                      _sensorCard(
                        Icons.air,
                        wind == null
                            ? "--"
                            : "${wind!.speed.toStringAsFixed(1)} м/с",
                        const Color(0xFF64D2FF), // iOS Cyan
                      ),
                      _sensorCard(
                        Icons.thermostat,
                        temp == null
                            ? "--"
                            : "${temp!.temperature.toStringAsFixed(1)}°",
                        const Color(0xFFFF9F0A), // iOS Orange
                      ),
                      _sensorCard(
                        Icons.water_drop_outlined,
                        humidity == null
                            ? "--"
                            : "${humidity!.humidity.toStringAsFixed(0)}%",
                        const Color(0xFF0A84FF), // iOS Blue
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  // Last Telemetry Timestamp
                  Text(
                    _lastSensorDataTime(0, wind),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.1,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _lastSensorDataTime(1, wind),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                      color: Color(0xFF30D158), // iOS Vibrant Green
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Apple Refresh Floating Wheel
                  RotationTransition(
                    turns: _refreshController,
                    child: _glassIcon(
                      Icons.refresh_rounded,
                      refreshData,
                      size: 64,
                      iconSize: 28,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // iOS Styled Call-to-Action Statistics Trigger
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) =>
                            SensorStatsScreen(repository: SensorRepository()),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 0.5,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bar_chart_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Статистика",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sensorCard(IconData icon, String value, Color accentColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(icon, size: 26, color: accentColor),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassIcon(
    IconData icon,
    VoidCallback onTap, {
    double size = 44,
    double iconSize = 22,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 0.5,
              ),
            ),
            child: Center(
              child: Icon(icon, color: Colors.white, size: iconSize),
            ),
          ),
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
  bool? sensorActive;
  bool checkingStatus = false;
  bool infinite = false;
  bool actionLoading = false;
  String? errorMessage;

  Map<String, bool?> sensorsStatus = {
    "wind_speed": null,
    "temperature": null,
    "humidity": null,
  };

  late final AutoCollectRepository autoCollectRepo;
  bool autoCollStatus = false;
  final durationController = TextEditingController();
  final periodController = TextEditingController(text: "1000");

  @override
  void initState() {
    super.initState();
    autoCollectRepo = AutoCollectRepository();
    for (final s in sensorsStatus.keys) {
      checkSensorStatus(s);
    }
  }

  @override
  void dispose() {
    durationController.dispose();
    periodController.dispose();
    super.dispose();
  }

  Future<void> autoColl(String sensor, int duration, int period) async {
    setState(() => actionLoading = true);
    try {
      var w = await autoCollectRepo.startAutoCollect(
        sensor: sensor,
        duration: duration,
        period: period,
      );
      setState(() {
        autoCollStatus = w.success;
        sensorActive = w.success;
        sensorsStatus[sensor] = w.success;
      });
    } catch (e) {
      errorMessage =
          "Не удалось запустить автоматический сбор для сенсора: $sensor";
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  Future<void> checkSensorStatus(String sensor) async {
    setState(() {
      checkingStatus = true;
      sensorsStatus[sensor] = null;
    });

    try {
      final status = await autoCollectRepo.getSensorStatus(sensor);
      if (!mounted) return;
      setState(() {
        sensorsStatus[sensor] = status;
        if (this.sensor == sensor) sensorActive = status;
      });
    } catch (e) {
      print(e);
      errorMessage = "Ошибка получения статуса сенсора";
      if (mounted) setState(() => sensorsStatus[sensor] = false);
    } finally {
      if (mounted) setState(() => checkingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
        child: Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom + 34,
          ),
          decoration: BoxDecoration(
            color: const Color(0xDC1C1C1E), // iOS Elevation Dark Color
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // iOS Notch Indicator
              Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Автосбор",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              if (errorMessage != null) _buildAppleErrorCard(),
              _statusCard(),
              const SizedBox(height: 20),
              _startSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppleErrorCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF453A).withOpacity(0.12), // iOS Destructive Red
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFF453A).withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFF453A),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: Color(0xFFFF453A),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _miniStat(Icons.air, sensorsStatus["wind_speed"]),
          _miniStat(Icons.thermostat, sensorsStatus["temperature"]),
          _miniStat(Icons.water_drop_outlined, sensorsStatus["humidity"]),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, bool? status) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.6), size: 18),
        const SizedBox(width: 8),
        if (status == null)
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white54,
            ),
          )
        else
          Icon(
            status ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: status ? const Color(0xFF30D158) : const Color(0xFFFF453A),
            size: 16,
          ),
      ],
    );
  }

  Widget _startSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sensorSelector(),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buildStateContent(),
        ),
      ],
    );
  }

  Widget _buildStateContent() {
    if (checkingStatus) {
      return const Center(
        key: ValueKey("loading_state"),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    if (sensorActive == true) {
      return _activeSensorView(key: const ValueKey("active_state"));
    }
    return _inactiveSensorView(key: const ValueKey("inactive_state"));
  }

  Widget _activeSensorView({Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF30D158).withOpacity(0.08),
        border: Border.all(
          color: const Color(0xFF30D158).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF30D158),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "Сенсор выполняет автосбор",
                style: TextStyle(
                  color: Color(0xFF30D158),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextButton(
              onPressed: () async {
                setState(() => actionLoading = true);
                try {
                  await autoCollectRepo.stopAutoCollect(sensor);
                  if (mounted) {
                    setState(() {
                      sensorActive = false;
                      sensorsStatus[sensor] = false;
                    });
                  }
                } catch (e) {
                  errorMessage = "Не удалось остановить сенсор: $sensor";
                } finally {
                  if (mounted) setState(() => actionLoading = false);
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFF453A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Остановить сбор",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inactiveSensorView({Key? key}) {
    return Column(
      key: key,
      children: [
        _inputField(
          controller: durationController,
          label: "Продолжительность (сек)",
          enabled: !infinite,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              "Бесконечный сбор",
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(width: 4),
            Switch.adaptive(
              value: infinite,
              activeColor: const Color(0xFF0A84FF),
              onChanged: (v) => setState(() => infinite = v),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _inputField(
          controller: periodController,
          label: "Интервал опроса (мс, ≥1000)",
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: TextButton(
            onPressed: actionLoading
                ? null
                : () {
                    final period = int.tryParse(periodController.text) ?? 1000;
                    if (period < 1000) return;
                    final duration = infinite
                        ? 0
                        : int.tryParse(durationController.text) ?? 0;
                    autoColl(sensor, duration, period);
                  },
            style: TextButton.styleFrom(
              backgroundColor: actionLoading
                  ? Colors.white24
                  : const Color(0xFF0A84FF),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white38,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              actionLoading ? "Запуск..." : "Запустить поток",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sensorSelector() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black.withOpacity(0.3),
      ),
      child: Row(
        children: [
          _sensorItem("wind_speed", Icons.air),
          _sensorItem("temperature", Icons.thermostat),
          _sensorItem("humidity", Icons.water_drop_outlined),
        ],
      ),
    );
  }

  Widget _sensorItem(String value, IconData icon) {
    final selected = sensor == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => sensor = value);
          checkSensorStatus(value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: selected
                ? Colors.white.withOpacity(0.12)
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? Colors.white.withOpacity(0.08)
                  : Colors.transparent,
              width: 0.5,
            ),
          ),
          child: Icon(
            icon,
            color: selected ? Colors.white : Colors.white.withOpacity(0.4),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 14,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.03),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.06),
              width: 0.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0A84FF), width: 1),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.02)),
          ),
        ),
      ),
    );
  }
}
