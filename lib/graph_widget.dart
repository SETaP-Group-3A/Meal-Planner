import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/graph_controller.dart';

class ProgressGraphWidget extends StatefulWidget {
  final dynamic userData;
  const ProgressGraphWidget({super.key, required this.userData});

  @override
  State<ProgressGraphWidget> createState() => _ProgressGraphWidgetState();
}

class _ProgressGraphWidgetState extends State<ProgressGraphWidget> {
  late GraphController controller;
  late List<int> goalData;

  final List<String> xTitles = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];

  @override
  void initState() {
    super.initState();
    controller = GraphController(widget.userData);
    goalData = controller.updateGraph("calories");
  }

  @override
  void didUpdateWidget(covariant ProgressGraphWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userData != oldWidget.userData) {
      controller = GraphController(widget.userData);
      setState(() {
        goalData = controller.updateGraph("calories");
      });
    }
  }

  List<FlSpot> formatData() {
    final temp = <FlSpot>[];
    for (int i = 0; i < goalData.length; i++) {
      temp.add(FlSpot((i + 1).toDouble(), goalData[i].toDouble()));
    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(spots: formatData(), color: Colors.green),
        ],
        minX: 1,
        maxX: 7,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 32,
              getTitlesWidget: xTitlesWidgets,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }

  Widget xTitlesWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(meta: meta, child: Text(xTitles[value.toInt() - 1]));
  }
}