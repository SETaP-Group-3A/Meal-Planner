import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProgressGraphWidget extends StatelessWidget {
  final List<int> goalData;

  ProgressGraphWidget({super.key, required this.goalData});

  final List<String> xTitles = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];

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
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 32,
              getTitlesWidget: xTitlesWidgets,
            ),
          ),
          rightTitles: AxisTitles( sideTitles: SideTitles( showTitles: false )),
          topTitles: AxisTitles( sideTitles: SideTitles( showTitles: false ))
      )
      )
    );
  }

  Widget xTitlesWidgets(double value, TitleMeta meta) {

    return SideTitleWidget(meta: meta, child: Text(xTitles[value.toInt() - 1])); 
    } 
  }