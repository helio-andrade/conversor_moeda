import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/history_point.dart';

class HistoryChartCard extends StatelessWidget {
  const HistoryChartCard({
    super.key,
    required this.title,
    required this.color,
    required this.valuesFuture,
    required this.weeks,
    this.compact = false,
  });

  final String title;
  final Color color;
  final Future<List<HistoryPoint>> valuesFuture;
  final int weeks;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HistoryPoint>>(
      future: valuesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Erro ao carregar historico de $title',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }

        final values = snapshot.data ?? <HistoryPoint>[];
        final spots = List.generate(
          values.length,
          (index) => FlSpot(index.toDouble(), values[index].value),
        );
        final weekMarkers = _buildWeekMarkers(values.length);

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: EdgeInsets.all(compact ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: compact ? 180 : 220,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (!_isWeekMarker(index, values.length)) {
                                return const SizedBox.shrink();
                              }
                              final weekNumber = (index / 7).floor() + 1;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'S$weekNumber',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      extraLinesData: ExtraLinesData(
                        verticalLines: weekMarkers,
                      ),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final index = spot.x.toInt();
                              if (index < 0 || index >= values.length) {
                                return null;
                              }

                              final point = values[index];
                              final precision = title.contains('BTC') ? 7 : 2;
                              return LineTooltipItem(
                                '${_formatDate(point.date)}\n${point.value.toStringAsFixed(precision)}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          barWidth: 3,
                          color: color,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<VerticalLine> _buildWeekMarkers(int length) {
    if (length <= 1) {
      return const <VerticalLine>[];
    }

    final markers = <VerticalLine>[];
    for (var day = 0; day < length; day += 7) {
      markers.add(
        VerticalLine(
          x: day.toDouble(),
          color: Colors.white24,
          strokeWidth: 1,
          dashArray: const [4, 4],
        ),
      );
    }
    return markers;
  }

  bool _isWeekMarker(int index, int length) {
    if (index < 0 || index >= length) {
      return false;
    }
    if (index % 7 == 0) {
      return true;
    }
    return index == length - 1 && weeks == 1;
  }

  String _formatDate(DateTime date) {
    final day = _twoDigits(date.day);
    final month = _twoDigits(date.month);
    return '$day/$month/${date.year}';
  }

  String _twoDigits(int value) {
    return value < 10 ? '0$value' : '$value';
  }
}
