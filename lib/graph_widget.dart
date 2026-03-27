import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/models/weekly_goals.dart';
import 'package:meal_planner/repositories/graph_controller.dart';

class ProgressGraphWidget extends StatefulWidget {

  final List<Goal> userData;

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
    goalData = controller.updateGraph(widget.userData[0].id);
  }

  @override
  void didUpdateWidget(covariant ProgressGraphWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userData != oldWidget.userData) {
      controller = GraphController(widget.userData);
      setState(() {
        goalData = controller.updateGraph(widget.userData[0].id);
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
        lineTouchData: LineTouchData(
          touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
            if (event is FlTapUpEvent) {
              final touched = response?.lineBarSpots?.first;
              if (touched != null) {
                _onPointTapped(touched);
              }
            }
          },
        ),
        lineBarsData: [
          LineChartBarData(
            spots: formatData(),
            color: Colors.green,
            isCurved: true,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.green, Colors.lightGreen.withValues(alpha: 0.08)],
              ),
            ),
          ),
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

  void _onPointTapped(LineBarSpot touched) {
    final x = touched.x.toInt();
    final int dayIndex = (x - 1).clamp(0, 6);
    Navigator.of(context).pushNamed('/diary', arguments: {'dayIndex': dayIndex});
  }
}