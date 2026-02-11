import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProgressGraphWidget extends StatelessWidget {
  final List<int> goalData;

  const ProgressGraphWidget({super.key, required this.goalData});

  List<FlSpot> formatData() {
    final temp = <FlSpot>[];
    for (int i = 0; i < goalData.length; i++) {
      temp.add(FlSpot(
        (i + 1).toDouble(),
        goalData[i].toDouble(),
      ));
    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: formatData(),
            color: Colors.green,
          ),
        ],
        minX: 1,
        maxX: 7,
      ),
    );
  }
}
