import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:grpc/grpc.dart';
import 'dart:math';

import '../../domain/models/sensor_models.dart';
import '../../data/repository/sensor_repository.dart';
import '../../generated/iot404/service.pbgrpc.dart' as pb;

class SensorStatsScreen extends StatefulWidget {
  final SensorRepository repository;

  const SensorStatsScreen({super.key, required this.repository});

  @override
  State<SensorStatsScreen> createState() => _SensorStatsScreenState();
}

class _SensorStatsScreenState extends State<SensorStatsScreen> {
  pb.SensorType _selectedSensor = pb.SensorType.SENSOR_TYPE_TEMPERATURE;
  pb.PeriodType _selectedPeriod = pb.PeriodType.PERIOD_TYPE_DAY;
  int _periodOffset = 0;

  List<ChartDataPoint> _dayData = [];
  List<ChartAggregatedPoint> _aggregatedData = [];

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru', null);
    _loadDataFromServer(); // Первичный запрос данных при создании виджета
  }

  // Загрузка данных через изолированный gRPC репозиторий
  Future<void> _loadDataFromServer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.repository.fetchStats(
        sensor: _selectedSensor,
        period: _selectedPeriod,
        offset: _periodOffset,
      );

      setState(() {
        _dayData = result.dayData;
        _aggregatedData = result.aggregatedData;
        _isLoading = false;
      });
    } on GrpcError catch (e) {
      setState(() {
        _errorMessage = 'Ошибка сети: ${e.message ?? e.codeName}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Не удалось загрузить данные с сервера';
        _isLoading = false;
      });
    }
  }

  void _onDataStructureChanged() {
    _loadDataFromServer();
  }

  Widget _buildTimeNavigation() {
    String label = '';
    final now = DateTime.now();

    if (_selectedPeriod == pb.PeriodType.PERIOD_TYPE_DAY) {
      if (_periodOffset == 0) {
        label = 'Сегодня';
      } else if (_periodOffset == -1) {
        label = 'Вчера';
      } else {
        final targetDate = now.subtract(Duration(days: _periodOffset.abs()));
        label = DateFormat('d MMMM yyyy', 'ru').format(targetDate);
      }
    } else if (_selectedPeriod == pb.PeriodType.PERIOD_TYPE_WEEK) {
      if (_periodOffset == 0) {
        label = 'Текущая неделя';
      } else {
        final startOfWeek = now.subtract(
          Duration(days: _periodOffset.abs() * 7 + (now.weekday - 1)),
        );
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        label =
            '${DateFormat('d.MM').format(startOfWeek)} – ${DateFormat('d.MM.yy').format(endOfWeek)}';
      }
    } else if (_selectedPeriod == pb.PeriodType.PERIOD_TYPE_MONTH) {
      if (_periodOffset == 0) {
        label = DateFormat('LLLL yyyy', 'ru').format(now);
      } else {
        final targetMonth = DateTime(now.year, now.month + _periodOffset, 1);
        label = DateFormat('LLLL yyyy', 'ru').format(targetMonth);
      }
    }

    label = label[0].toUpperCase() + label.substring(1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 32,
            child: const Icon(
              CupertinoIcons.chevron_left,
              size: 20,
              color: CupertinoColors.activeBlue,
            ),
            onPressed: () {
              _periodOffset--;
              _onDataStructureChanged();
            },
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 32,
            onPressed: _periodOffset < 0
                ? () {
                    _periodOffset++;
                    _onDataStructureChanged();
                  }
                : null,
            child: Icon(
              CupertinoIcons.chevron_right,
              size: 20,
              color: _periodOffset < 0
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.placeholderText,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasData = _selectedPeriod == pb.PeriodType.PERIOD_TYPE_DAY
        ? _dayData.isNotEmpty
        : _aggregatedData.isNotEmpty;

    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      body: SafeArea(
        top: true,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              // Задаем фиксированный отступ 20 сверху (и по 4 по бокам для аккуратности)
              padding: const EdgeInsets.only(top: 20.0, left: 4.0, right: 4.0),
              sliver: SliverAppBar(
                // Убираем expandedHeight, делаем высоту фиксированной
                pinned: true,
                elevation: 0,
                automaticallyImplyLeading:
                    false, // Отключаем дефолтную кнопку Flutter
                backgroundColor: CupertinoColors.systemBackground,

                // Кнопка назад
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    CupertinoIcons.back,
                    color: CupertinoColors.activeBlue,
                    size: 28, // Стандартный размер для иконки назад в iOS
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),

                // Текст на том же уровне, что и кнопка
                centerTitle: true,
                title: Text(
                  'Статистика сенсоров',
                  style: TextStyle(
                    color: CupertinoColors.label.resolveFrom(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSensorSelector(),
                    const SizedBox(height: 16),
                    _buildPeriodSelector(),
                    const SizedBox(height: 12),
                    _buildTimeNavigation(),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _isLoading
                          ? _buildLoadingCard()
                          : _errorMessage != null
                          ? _buildErrorCard()
                          : hasData
                          ? _buildChartCard()
                          : _buildEmptyStateCard(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      key: const ValueKey('loading_state'),
      height: 320,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(
          context,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const CupertinoActivityIndicator(radius: 12),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      key: const ValueKey('error_state'),
      padding: const EdgeInsets.all(24),
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(
          context,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_circle,
            color: CupertinoColors.systemRed,
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            color: CupertinoColors.activeBlue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            borderRadius: BorderRadius.circular(8),
            onPressed: _loadDataFromServer,
            child: const Text(
              'Повторить',
              style: TextStyle(fontSize: 13, color: CupertinoColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorSelector() {
    return Row(
      children: [
        _sensorCard(
          pb.SensorType.SENSOR_TYPE_TEMPERATURE,
          CupertinoIcons.thermometer,
          'Темп.',
        ),
        _sensorCard(
          pb.SensorType.SENSOR_TYPE_HUMIDITY,
          CupertinoIcons.drop_fill,
          'Влажн.',
        ),
        _sensorCard(
          pb.SensorType.SENSOR_TYPE_WIND,
          CupertinoIcons.wind,
          'Ветер',
        ),
      ],
    );
  }

  Widget _sensorCard(pb.SensorType type, IconData icon, String label) {
    final isSelected = _selectedSensor == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedSensor == type) return;
          _selectedSensor = type;
          _periodOffset = 0;
          _onDataStructureChanged();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? CupertinoColors.activeBlue
                : CupertinoColors.secondarySystemGroupedBackground.resolveFrom(
                    context,
                  ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? CupertinoColors.white
                    : CupertinoColors.activeBlue,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? CupertinoColors.white
                      : CupertinoColors.secondaryLabel,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoSlidingSegmentedControl<pb.PeriodType>(
        groupValue: _selectedPeriod,
        backgroundColor: CupertinoColors.tertiarySystemFill,
        thumbColor: CupertinoColors.secondarySystemGroupedBackground
            .resolveFrom(context),
        children: const {
          pb.PeriodType.PERIOD_TYPE_DAY: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('День', style: TextStyle(fontSize: 13)),
          ),
          pb.PeriodType.PERIOD_TYPE_WEEK: Text(
            'Неделя',
            style: TextStyle(fontSize: 13),
          ),
          pb.PeriodType.PERIOD_TYPE_MONTH: Text(
            'Месяц',
            style: TextStyle(fontSize: 13),
          ),
        },
        onValueChanged: (value) {
          if (value != null) {
            _periodOffset = 0;
            _selectedPeriod = value;
            _onDataStructureChanged();
          }
        },
      ),
    );
  }

  Widget _buildEmptyStateCard() => Container(
    key: const ValueKey('empty_state'),
    height: 320,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(
        context,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      'Нет данных',
      style: TextStyle(
        color: CupertinoColors.secondaryLabel.resolveFrom(context),
      ),
    ),
  );

  Widget _buildChartCard() {
    return Container(
      key: const ValueKey('chart_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(
          context,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedSensor == pb.SensorType.SENSOR_TYPE_TEMPERATURE
                ? 'График температуры, °C'
                : _selectedSensor == pb.SensorType.SENSOR_TYPE_HUMIDITY
                ? 'График влажности, %'
                : 'Скорость ветра, м/с',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          SizedBox(height: 220, child: LineChart(_getChartData())),
          if (_selectedPeriod != pb.PeriodType.PERIOD_TYPE_DAY) ...[
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem('Макс', CupertinoColors.systemRed),
        const SizedBox(width: 16),
        _legendItem('Средн', CupertinoColors.systemGreen),
        const SizedBox(width: 16),
        _legendItem('Мин', CupertinoColors.systemBlue),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
      ],
    );
  }

  LineChartData _getChartData() {
    final isDay = _selectedPeriod == pb.PeriodType.PERIOD_TYPE_DAY;

    double minY = 0.0;
    double maxY = 100.0;

    if (isDay && _dayData.isNotEmpty) {
      final values = _dayData.map((e) => e.value).toList();
      minY = values.reduce(min);
      maxY = values.reduce(max);
    } else if (!isDay && _aggregatedData.isNotEmpty) {
      final minValues = _aggregatedData.map((e) => e.min).toList();
      final maxValues = _aggregatedData.map((e) => e.max).toList();
      minY = minValues.reduce(min);
      maxY = maxValues.reduce(max);
    }

    double delta = maxY - minY;
    if (delta == 0) delta = 1;
    minY = (minY - delta * 0.1).roundToDouble();
    maxY = (maxY + delta * 0.1).roundToDouble();

    double yInterval = (maxY - minY) / 5;
    yInterval = yInterval == 0 ? 1 : yInterval;

    return LineChartData(
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: CupertinoColors.separator.withOpacity(0.15),
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            interval: yInterval,
            getTitlesWidget: (val, meta) {
              return SideTitleWidget(
                meta: meta,
                space: 6,
                child: Text(
                  val.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 10,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (value, meta) {
              int idx = value.toInt();
              if (isDay) {
                if (idx < 0 ||
                    idx >= _dayData.length ||
                    idx % (max(1, _dayData.length ~/ 4)) != 0) {
                  return const SizedBox();
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(
                    DateFormat('HH:mm').format(_dayData[idx].timestamp),
                    style: const TextStyle(
                      fontSize: 10,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                );
              } else {
                if (idx < 0 || idx >= _aggregatedData.length)
                  return const SizedBox();
                int labelInterval =
                    _selectedPeriod == pb.PeriodType.PERIOD_TYPE_WEEK ? 1 : 6;
                if (idx % labelInterval != 0) return const SizedBox();

                final date = _aggregatedData[idx].date;
                String formatted =
                    _selectedPeriod == pb.PeriodType.PERIOD_TYPE_WEEK
                    ? DateFormat('E', 'ru').format(date)
                    : DateFormat('dd.MM').format(date);
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(
                    formatted,
                    style: const TextStyle(
                      fontSize: 10,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (spot) => CupertinoColors.black.withOpacity(0.85),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final idx = spot.x.toInt();
              String timeHeader = '';
              if (isDay) {
                timeHeader = DateFormat(
                  'HH:mm',
                ).format(_dayData[idx].timestamp);
              } else {
                timeHeader = DateFormat(
                  'dd.MM.yyyy',
                ).format(_aggregatedData[idx].date);
              }

              String prefix = '';
              if (!isDay) {
                if (spot.barIndex == 0) prefix = 'Макс: ';
                if (spot.barIndex == 1) prefix = 'Средн: ';
                if (spot.barIndex == 2) prefix = 'Мин: ';
              }

              return LineTooltipItem(
                '$timeHeader\n$prefix${spot.y.toStringAsFixed(1)}',
                const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: isDay ? _getDayBars() : _getAggregatedBars(),
    );
  }

  List<LineChartBarData> _getDayBars() {
    return [
      LineChartBarData(
        spots: _dayData
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.value))
            .toList(),
        isCurved: true,
        color: CupertinoColors.activeBlue,
        barWidth: 3,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: CupertinoColors.activeBlue.withOpacity(0.08),
        ),
      ),
    ];
  }

  List<LineChartBarData> _getAggregatedBars() {
    final maxSpots = _aggregatedData
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.max))
        .toList();
    final avgSpots = _aggregatedData
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.avg))
        .toList();
    final minSpots = _aggregatedData
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.min))
        .toList();

    LineChartBarData barSetup(List<FlSpot> spots, Color color) {
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 2.5,
        dotData: const FlDotData(show: false),
      );
    }

    return [
      barSetup(maxSpots, CupertinoColors.systemRed),
      barSetup(avgSpots, CupertinoColors.systemGreen),
      barSetup(minSpots, CupertinoColors.systemBlue),
    ];
  }
}
