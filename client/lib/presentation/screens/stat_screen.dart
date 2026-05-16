import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/repository/wind_repository.dart';
import '../../data/datasource/wind_remote.dart';

enum SensorType { temperature, wind, humidity, all }

enum Period { day, week, month }

class StatsSheet extends StatefulWidget {
  const StatsSheet({super.key});

  @override
  State<StatsSheet> createState() => _StatsSheetState();
}

class _StatsSheetState extends State<StatsSheet> {
  SensorType selectedSensor = SensorType.temperature;
  Period selectedPeriod = Period.day;
  late final WindRepository windRepo;

  DateTime currentDate = DateTime.now();

  List<SensorPoint> tempPoints = [];
  List<SensorPoint> windPoints = [];
  List<SensorPoint> humidityPoints = [];

  bool isLoading = false;
  bool noData = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    windRepo = WindRepository(WindRemoteDataSource());
  }

  (DateTime from, DateTime to) _getRange() {
    switch (selectedPeriod) {
      case Period.day:
        final start = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        );
        final end = start.add(const Duration(days: 1));
        return (start, end);

      case Period.week:
        final start = currentDate.subtract(
          Duration(days: currentDate.weekday - 1),
        );
        final normalized = DateTime(start.year, start.month, start.day);
        return (normalized, normalized.add(const Duration(days: 7)));

      case Period.month:
        final start = DateTime(currentDate.year, currentDate.month, 1);
        final end = DateTime(currentDate.year, currentDate.month + 1, 1);
        return (start, end);
    }
  }

  Future<void> _loadData() async {
    final (from, to) = _getRange();

    setState(() {
      isLoading = true;
      noData = false;
    });

    try {
      if (selectedSensor == SensorType.temperature ||
          selectedSensor == SensorType.all) {
        // tempPoints = await getTemperatureStats(from, to);
        tempPoints = await windRepo.getWindStats(from, to);
      }

      if (selectedSensor == SensorType.wind ||
          selectedSensor == SensorType.all) {
        windPoints = await windRepo.getWindStats(from, to);
      }

      if (selectedSensor == SensorType.humidity ||
          selectedSensor == SensorType.all) {
        // humidityPoints = await getHumidityStats(from, to);
        humidityPoints = await windRepo.getWindStats(from, to);
      }
    } catch (e) {
      // 👇 твой 404
      noData = true;
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget _buildDateNavigator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              currentDate = _prevPeriod();
            });
            _loadData();
          },
          icon: const Icon(Icons.chevron_left, color: Colors.white),
        ),

        Text(_formatRangeLabel(), style: const TextStyle(color: Colors.white)),

        IconButton(
          onPressed: () {
            setState(() {
              currentDate = _nextPeriod();
            });
            _loadData();
          },
          icon: const Icon(Icons.chevron_right, color: Colors.white),
        ),
      ],
    );
  }

  DateTime _prevPeriod() {
    switch (selectedPeriod) {
      case Period.day:
        return currentDate.subtract(const Duration(days: 1));
      case Period.week:
        return currentDate.subtract(const Duration(days: 7));
      case Period.month:
        return DateTime(
          currentDate.year,
          currentDate.month - 1,
          currentDate.day,
        );
    }
  }

  DateTime _nextPeriod() {
    switch (selectedPeriod) {
      case Period.day:
        return currentDate.add(const Duration(days: 1));
      case Period.week:
        return currentDate.add(const Duration(days: 7));
      case Period.month:
        return DateTime(
          currentDate.year,
          currentDate.month + 1,
          currentDate.day,
        );
    }
  }

  String _formatRangeLabel() {
    final (from, to) = _getRange();

    return "${from.day}.${from.month}.${from.year} - ${to.day}.${to.month}.${from.year}";
  }

  List<FlSpot> _toSpots(List<SensorPoint> points) {
    return List.generate(points.length, (i) {
      return FlSpot(i.toDouble(), points[i].value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 520,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xff171c25),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildDateNavigator(),
          const SizedBox(height: 10),

          _buildSensorSelector(),
          const SizedBox(height: 12),

          _buildPeriodSelector(),
          const SizedBox(height: 20),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : noData
                ? const Center(
                    child: Text(
                      "Нет данных за период",
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : _buildChart(),
          ),

          if (selectedSensor == SensorType.all) _buildLegend(),
        ],
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _buildHeader() {
    return const Text(
      "Статистика",
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ---------------- SENSOR SELECT ----------------
  Widget _buildSensorSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: SensorType.values.map((sensor) {
        final isSelected = selectedSensor == sensor;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => selectedSensor = sensor);
              _loadData();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _sensorIcon(sensor),
                color: isSelected ? Colors.white : Colors.white54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _sensorIcon(SensorType type) {
    switch (type) {
      case SensorType.temperature:
        return Icons.thermostat;
      case SensorType.wind:
        return Icons.air;
      case SensorType.humidity:
        return Icons.water_drop;
      case SensorType.all:
        return Icons.multiline_chart;
    }
  }

  String _sensorShort(SensorType type) {
    switch (type) {
      case SensorType.temperature:
        return "Temp";
      case SensorType.wind:
        return "Wind";
      case SensorType.humidity:
        return "Hum";
      case SensorType.all:
        return "";
    }
  }

  LineChartBarData _line(List<FlSpot> data, Color color) {
    return LineChartBarData(
      isCurved: true,
      spots: data,
      color: color,
      barWidth: 3,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: true, color: color.withOpacity(0.08)),
    );
  }

  // ---------------- PERIOD SELECT ----------------
  Widget _buildPeriodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: Period.values.map((p) {
        final isSelected = selectedPeriod == p;

        return GestureDetector(
          onTap: () {
            setState(() => selectedPeriod = p);
            _loadData();
          },
          child: Text(
            _periodName(p),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _periodName(Period p) {
    switch (p) {
      case Period.day:
        return "Day";
      case Period.week:
        return "Week";
      case Period.month:
        return "Month";
    }
  }

  // ---------------- CHART ----------------
  Widget _buildChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getYInterval(),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.05),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),

        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBorderRadius: BorderRadius.circular(12),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();

                SensorPoint point;

                final sensor = _getSensorFromBar(spot.barIndex);

                switch (sensor) {
                  case SensorType.temperature:
                    point = tempPoints[index];
                    break;
                  case SensorType.wind:
                    point = windPoints[index];
                    break;
                  case SensorType.humidity:
                    point = humidityPoints[index];
                    break;
                  case SensorType.all:
                    point = tempPoints[index];
                    break;
                }

                final unit = _getUnit(sensor);

                return LineTooltipItem(
                  "${_formatDate(point.time)}\n"
                  "${_sensorShort(sensor)}: ${spot.y.toStringAsFixed(1)} $unit",
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),

        titlesData: _titlesData(),
        lineBarsData: _getLines(),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    switch (selectedPeriod) {
      case Period.day:
        return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      case Period.week:
        return "${dt.day}.${dt.month}.${dt.year}";
      case Period.month:
        return "${dt.day}.${dt.month}.${dt.year}";
    }
  }

  SensorType _getSensorFromBar(int index) {
    final visible = <SensorType>[];

    if (selectedSensor == SensorType.temperature ||
        selectedSensor == SensorType.all) {
      visible.add(SensorType.temperature);
    }

    if (selectedSensor == SensorType.wind || selectedSensor == SensorType.all) {
      visible.add(SensorType.wind);
    }

    if (selectedSensor == SensorType.humidity ||
        selectedSensor == SensorType.all) {
      visible.add(SensorType.humidity);
    }

    if (index >= visible.length) {
      return SensorType.temperature;
    }

    return visible[index];
  }

  double _getYInterval() {
    switch (selectedSensor) {
      case SensorType.temperature:
        return 2;
      case SensorType.wind:
        return 1;
      case SensorType.humidity:
        return 10;
      case SensorType.all:
        return 10;
    }
  }

  double _getXInterval() {
    switch (selectedPeriod) {
      case Period.day:
        return 1; // часы
      case Period.week:
        return 1; // дни
      case Period.month:
        return 1; // дни
    }
  }

  String _getBottomLabel(int value) {
    switch (selectedPeriod) {
      case Period.day:
        return "${value * 4}:00";
      // если у тебя 6 точек = каждые 4 часа

      case Period.week:
        const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
        if (value >= 0 && value < days.length) {
          return days[value];
        }
        return "";

      case Period.month:
        return value.toString(); // дни месяца
    }
  }

  String _getUnit(SensorType s) {
    switch (s) {
      case SensorType.temperature:
        return "°C";
      case SensorType.wind:
        return "m/s";
      case SensorType.humidity:
        return "%";
      case SensorType.all:
        return "";
    }
  }

  List<LineChartBarData> _getLines() {
    final lines = <LineChartBarData>[];

    if (selectedSensor == SensorType.temperature ||
        selectedSensor == SensorType.all) {
      lines.add(_line(_toSpots(tempPoints), Colors.orange));
    }

    if (selectedSensor == SensorType.wind || selectedSensor == SensorType.all) {
      lines.add(_line(_toSpots(windPoints), Colors.blueAccent));
    }

    if (selectedSensor == SensorType.humidity ||
        selectedSensor == SensorType.all) {
      lines.add(_line(_toSpots(humidityPoints), Colors.green));
    }

    return lines;
  }

  // ---------------- LEGEND ----------------
  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem("Temp", Colors.orange),
          _legendItem("Wind", Colors.blue),
          _legendItem("Hum", Colors.green),
        ],
      ),
    );
  }

  FlTitlesData _titlesData() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 42,
          interval: _getYInterval(),
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                _leftLabel(value),
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            );
          },
        ),
      ),

      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: _getXInterval(),
          getTitlesWidget: (value, meta) {
            final text = _getBottomLabel(value.toInt());

            if (text.isEmpty) return const SizedBox();

            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                text,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            );
          },
        ),
      ),

      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  String _leftLabel(double value) {
    if (selectedSensor == SensorType.all) {
      return value.toInt().toString();
    }

    return "${value.toInt()} ${_getUnit(selectedSensor)}";
  }

  Widget _legendItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(width: 10, height: 10, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: "AppleSanFrancisco",
            ),
          ),
        ],
      ),
    );
  }
}
