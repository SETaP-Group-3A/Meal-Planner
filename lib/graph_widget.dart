import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProgressGraphWidget extends StatelessWidget {
  final Map<double, double> dataPoints;

  const ProgressGraphWidget({super.key, required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: dataPoints.keys
                .map((double data) => FlSpot(data, dataPoints[data]!))
                .toList(),
            color: Colors.green
          ),
        ],
        minX: 1,
        maxX: 7,
      ),
    );
  }
}
