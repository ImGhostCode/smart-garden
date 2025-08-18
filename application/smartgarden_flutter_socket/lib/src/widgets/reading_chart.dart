import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/sensor_reading.dart';

class ReadingChart extends StatelessWidget {
  final List<SensorReading> readings;
  const ReadingChart({super.key, required this.readings});

  @override
  Widget build(BuildContext context) {
    final tempSpots = <FlSpot>[];
    final humSpots = <FlSpot>[];

    final sorted = readings.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    for (var i = 0; i < sorted.length; i++) {
      final r = sorted[i];
      if (r.temperature != null) tempSpots.add(FlSpot(i.toDouble(), r.temperature!));
      if (r.humidity != null) humSpots.add(FlSpot(i.toDouble(), r.humidity!));
    }

    return LineChart(
      LineChartData(
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
        lineTouchData: const LineTouchData(enabled: true),
        lineBarsData: [
          LineChartBarData(spots: tempSpots, isCurved: true, dotData: const FlDotData(show: false)),
          LineChartBarData(spots: humSpots, isCurved: true, dotData: const FlDotData(show: false)),
        ],
      ),
    );
  }
}
