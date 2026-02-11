import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

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
          ),
        ],
      ),
    );
  }
}
