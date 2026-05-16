import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../data/repository/wind_repository.dart';
import '../../data/datasource/wind_remote.dart';

enum SensorType { temperature, wind, humidity }

enum Period { day, week, month }

class StatsSheet extends StatefulWidget {
  const StatsSheet({super.key});
  @override
  State<StatsSheet> createState() => _StatsSheetState();
}

class _StatsSheetState extends State<StatsSheet> {
  List<Color> gradientColors = [
    Colors.teal.shade400,
    Colors.tealAccent.shade400,
  ];
  SensorType selectedSensor = SensorType.wind;
  Period selectedPeriod = Period.day;
  DateTime selectedDateFrom = DateTime.now();
  DateTime selectedDateTo = DateTime.now();
  List<SensorPoint> temperaturePoints = [];
  List<SensorPoint> windPoints = [];
  List<SensorPoint> humidityPoints = [];
  late final WindRepository windRepo;
  bool isLoading = false;
  bool noData = false;
  @override
  void initState() {
    super.initState();
    windRepo = WindRepository(WindRemoteDataSource());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      noData = false;
    });
    try {
      switch (selectedSensor) {
        case SensorType.temperature:
          temperaturePoints = await windRepo.getWindStats(
            selectedDateFrom,
            selectedDateTo,
          ); // await getTemperatureStats(from, to)
          break;
        case SensorType.wind:
          windPoints = await windRepo.getWindStats(
            selectedDateFrom,
            selectedDateTo,
          );
          break;
        case SensorType.humidity:
          humidityPoints = await windRepo.getWindStats(
            selectedDateFrom,
            selectedDateTo,
          ); // await getHumidityStats(from, to)
          break;
      }
    } catch (e) {
      // 👇 твой 404
      noData = true;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext ctx) {
    return Container(
      height: 600,
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xff171c25),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Text(
                "Статистика",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: "AppleSanFrancisco",
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              _buildSensorSelector(),
              const SizedBox(height: 15),
              _buildPeriodSelector(),
              const SizedBox(height: 15),
              _buildDateNavigator(),
              const SizedBox(height: 25),
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
            ],
          ),
        ],
      ),
    );
  }

  List<SensorPoint> _getCurrentPoints() {
    switch (selectedSensor) {
      case SensorType.temperature:
        return temperaturePoints;
      case SensorType.wind:
        return windPoints;
      case SensorType.humidity:
        return humidityPoints;
    }
  }

  (double min, double max) _getYBounds() {
    final points = _getCurrentPoints();
    if (points.isEmpty) return (0, 1);

    final values = points.map((e) => e.value);

    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);

    if (min == max) return (min - 1, max + 1);

    return (min, max);
  }

  double _getYInterval() {
    final bounds = _getYBounds();
    final range = bounds.$2 - bounds.$1;

    if (range == 0) return 1;

    return range / 4;
  }

  Widget _buildChart() {
    if (_getCurrentPoints().isEmpty) {
      return const Center(
        child: Text("Нет данных", style: TextStyle(color: Colors.white54)),
      );
    }
    var bounds = _getYBounds();
    return LineChart(
      LineChartData(
        minX: selectedDateFrom.millisecondsSinceEpoch.toDouble(),
        maxX: selectedDateTo.millisecondsSinceEpoch.toDouble(),
        minY: bounds.$1,
        maxY: bounds.$2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getYInterval(),
          verticalInterval: _getXInterval(),
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.white.withAlpha(5), strokeWidth: 1);
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
                SensorPoint point;

                switch (selectedSensor) {
                  case SensorType.temperature:
                    point = _findClosestPoint(temperaturePoints, spot.x);
                    break;
                  case SensorType.wind:
                    point = _findClosestPoint(windPoints, spot.x);
                    break;
                  case SensorType.humidity:
                    point = _findClosestPoint(humidityPoints, spot.x);
                    break;
                }
                final unit = _getUnit(selectedSensor);
                return LineTooltipItem(
                  "${_formatTooltipDate(point.time, selectedPeriod)}\n"
                  "${_sensorShortName(selectedSensor)}: ${spot.y.toStringAsFixed(1)} $unit",
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
        titlesData: _titlesData(),
        lineBarsData: _getLines(selectedSensor),
      ),
    );
  }

  List<LineChartBarData> _getLines(SensorType s) {
    var lines = <LineChartBarData>[];
    switch (s) {
      case SensorType.temperature:
        lines.add(_line(_toSpots(temperaturePoints), Colors.orange));
        break;
      case SensorType.wind:
        lines.add(_line(_toSpots(windPoints), Colors.blueAccent));
        break;
      case SensorType.humidity:
        lines.add(_line(_toSpots(humidityPoints), Colors.green));
        break;
    }
    return lines;
  }

  List<FlSpot> _toSpots(List<SensorPoint> points) {
    points.sort((a, b) => a.time.compareTo(b.time)); // 🔥 обязательно

    return points.map((p) {
      return FlSpot(p.time.millisecondsSinceEpoch.toDouble(), p.value);
    }).toList();
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

  String _formatTooltipDate(DateTime dt, Period p) {
    switch (p) {
      case Period.day:
        return "Время: ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      case Period.week:
        return "День: ${dt.day}.${dt.month}.${dt.year}";
      case Period.month:
        return "День: ${dt.day}.${dt.month}.${dt.year}";
    }
  }

  int _getXSegments() {
    switch (selectedPeriod) {
      case Period.day:
        return 6;
      case Period.week:
        return 7;
      case Period.month:
        return 10;
    }
  }

  SensorPoint _findClosestPoint(List<SensorPoint> points, double x) {
    SensorPoint closest = points.first;
    double minDiff = (closest.time.millisecondsSinceEpoch - x).abs();

    for (final p in points) {
      final diff = (p.time.millisecondsSinceEpoch - x).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = p;
      }
    }

    return closest;
  }

  double _getXInterval() {
    final range =
        selectedDateTo.millisecondsSinceEpoch -
        selectedDateFrom.millisecondsSinceEpoch;

    if (range == 0) return 1;
    return range / _getXSegments();
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
                value.toString(),
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
            final segments = _getXSegments();

            final range =
                selectedDateTo.millisecondsSinceEpoch -
                selectedDateFrom.millisecondsSinceEpoch;

            if (range <= 0) return const SizedBox();

            final step = range / segments;

            final index =
                ((value - selectedDateFrom.millisecondsSinceEpoch) / step)
                    .round();

            // показываем только ближайшие к сегментам точки
            final expectedX =
                selectedDateFrom.millisecondsSinceEpoch + step * index;

            if ((value - expectedX).abs() > step * 0.3) {
              return const SizedBox();
            }

            final dt = DateTime.fromMillisecondsSinceEpoch(expectedX.toInt());

            switch (selectedPeriod) {
              case Period.day:
                return Text(
                  DateFormat("HH:mm").format(dt),
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                );

              case Period.week:
                return Text(
                  DateFormat("MMM", "ru").format(dt),
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                );

              case Period.month:
                return Text(
                  DateFormat("dd").format(dt),
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                );
            }
          },
        ),
      ),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  String _getUnit(SensorType s) {
    switch (s) {
      case SensorType.temperature:
        return "°C";
      case SensorType.wind:
        return "m/s";
      case SensorType.humidity:
        return "%";
    }
  }

  String _sensorShortName(SensorType s) {
    switch (s) {
      case SensorType.temperature:
        return "Temp";
      case SensorType.wind:
        return "Wind";
      case SensorType.humidity:
        return "Hum";
    }
  }

  Widget _buildDateNavigator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              var pp = _prevPeriod();
              selectedDateFrom = pp.$1;
              selectedDateTo = pp.$2 == null ? selectedDateTo : pp.$2!;
            });
            _loadData();
          },
          icon: const Icon(Icons.chevron_left, color: Colors.white),
        ),
        Column(children: _formatDateRangeLabel()),
        IconButton(
          onPressed: () {
            setState(() {
              var pp = _nextPeriod();
              selectedDateFrom = pp.$1;
              selectedDateTo = pp.$2 == null ? selectedDateTo : pp.$2!;
            });
            _loadData();
          },
          icon: const Icon(Icons.chevron_right, color: Colors.white),
        ),
      ],
    );
  }

  (DateTime from, DateTime? to) _prevPeriod() {
    switch (selectedPeriod) {
      case Period.day:
        if (selectedDateFrom.add(Duration(days: 1)) == DateTime.now())
          return (selectedDateFrom, null);
        return (selectedDateFrom.subtract(const Duration(days: 1)), null);
      case Period.week:
        var to = selectedDateFrom.subtract(const Duration(days: 1));
        var from = to.subtract(const Duration(days: 7));
        return (from, to);
      case Period.month:
        var prevMonthLastDay = DateTime(
          selectedDateFrom.year,
          selectedDateFrom.month,
          1,
        ).subtract(Duration(days: 1));
        var prevMonthFirstDay = DateTime(
          prevMonthLastDay.year,
          prevMonthLastDay.month,
          1,
        );
        return (prevMonthFirstDay, prevMonthLastDay);
    }
  }

  (DateTime from, DateTime? to) _nextPeriod() {
    switch (selectedPeriod) {
      case Period.day:
        return (selectedDateFrom.add(Duration(days: 1)), null);
      case Period.week:
        var from = selectedDateTo.add(const Duration(days: 1));
        var to = from.add(Duration(days: 7));
        return (from, to);
      case Period.month:
        var nextMonthLastDay = DateTime(
          selectedDateFrom.year,
          selectedDateFrom.month + 2,
          1,
        );
        nextMonthLastDay = nextMonthLastDay.subtract(Duration(days: 1));
        var nextMonthFirstDay = DateTime(
          selectedDateFrom.year,
          selectedDateFrom.month + 1,
          1,
        );
        return (nextMonthFirstDay, nextMonthLastDay);
    }
  }

  List<Widget> _formatDateRangeLabel() {
    var result = List<Widget>.empty(growable: true);
    switch (selectedPeriod) {
      case Period.day:
        result.add(
          Text(
            DateFormat("dd.MM.yyyy").format(selectedDateFrom),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: "AppleSanFrancisco",
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        );
        break;
      case Period.month:
        var baseString = DateFormat("MMMM", "ru").format(selectedDateFrom);
        result.add(
          Text(
            baseString[0].toUpperCase() + baseString.substring(1).toLowerCase(),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: "AppleSanFrancisco",
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        );
        result.add(
          Text(
            selectedDateFrom.year.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: "AppleSanFrancisco",
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        );
        break;
      case Period.week:
        result.add(
          Text(
            "${DateFormat("dd.MM").format(selectedDateFrom)} - ${DateFormat("dd.MM").format(selectedDateTo)}",
            style: const TextStyle(
              color: Colors.white,
              fontFamily: "AppleSanFrancisco",
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        );
        result.add(SizedBox(height: 5));
        result.add(
          Text(
            selectedDateFrom.year != selectedDateTo.year
                ? "${DateFormat("yyyy").format(selectedDateFrom)} - ${DateFormat("yyyy").format(selectedDateTo)}"
                : DateFormat("yyyy").format(selectedDateFrom),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: "AppleSanFrancisco",
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        );
        break;
    }
    return result;
  }

  Widget _buildPeriodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: Period.values.map((p) {
        final isSelected = selectedPeriod == p;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedPeriod = p;
              final now = DateTime.now();
              switch (selectedPeriod) {
                case Period.day:
                  selectedDateFrom = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    0,
                    0,
                    0,
                    1,
                  );
                  selectedDateTo = now;
                  break;
                case Period.week:
                  selectedDateTo = now;
                  selectedDateFrom = selectedDateTo.subtract(
                    Duration(
                      days: 7,
                      hours: 23,
                      minutes: 59,
                      seconds: 59,
                      milliseconds: 998,
                    ),
                  );
                  break;
                case Period.month:
                  selectedDateFrom = DateTime(
                    now.year,
                    now.month,
                    1,
                    0,
                    0,
                    0,
                    1,
                  );
                  selectedDateTo = now;
                  break;
              }
            });
            _loadData();
          },
          child: Text(
            _periodName(p),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontWeight: FontWeight.w600,
              fontFamily: "AppleSanFrancisco",
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

  IconData _sensorIcon(SensorType s) {
    switch (s) {
      case SensorType.temperature:
        return Icons.thermostat;
      case SensorType.wind:
        return Icons.air;
      case SensorType.humidity:
        return Icons.water_drop;
    }
  }
}
