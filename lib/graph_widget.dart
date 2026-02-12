import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/graph_controller.dart';

class ProgressGraphWidget extends StatelessWidget {
  late List<int> goalData;

  late GraphController controller;

  //Replace var when type is known
  var userData;

  ProgressGraphWidget({super.key, required this.userData}) {
    controller = GraphController(userData); 
    goalData = controller.updateGraph("calories"); 
  }

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