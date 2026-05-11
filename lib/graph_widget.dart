import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/models/weekly_goals.dart';
import 'package:meal_planner/repositories/graph_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Test helper: when tests call `testPopulate`, the widget will render
// using this data instead of querying the DB.
List<Goal>? _graphTestData;
void testPopulate(List<Goal> data) => _graphTestData = data;
void testClear() => _graphTestData = null;

class ProgressGraphWidget extends StatefulWidget {
  const ProgressGraphWidget({super.key});

  @override
  State<ProgressGraphWidget> createState() => _ProgressGraphWidgetState();
}

class _ProgressGraphWidgetState extends State<ProgressGraphWidget> {
  late GraphController controller;
  late List<int> goalData;
  String? accountEmail;

  final List<String> xTitles = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];

  @override
  void initState() {
    super.initState();
    controller = GraphController([]);
    goalData = List<int>.filled(7, 0);
    // load saved account email for DB queries
    SharedPreferences.getInstance().then((prefs) {
      setState(() => accountEmail = prefs.getString('accountEmail'));
    });
  }

  @override
  void didUpdateWidget(covariant ProgressGraphWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  // Use controller to fetch DB-backed goals

  List<FlSpot> formatData() {
    final temp = <FlSpot>[];
    for (int i = 0; i < goalData.length; i++) {
      temp.add(FlSpot((i + 1).toDouble(), goalData[i].toDouble()));
    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Goal>>(
      stream: _graphTestData != null
          ? Stream.value(_graphTestData!)
          : Stream.periodic(const Duration(seconds: 2)).asyncMap((_) => controller.fetchLatestWeekGoals()),
      builder: (context, snap) {
        final goals = _graphTestData ?? (snap.data ?? []);
        if (goals.isEmpty) {
          controller = GraphController([]);
          goalData = List<int>.filled(7, 0);
        } else {
          controller = GraphController(goals);
          goalData = controller.updateGraph(goals[0].id);
        }

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
            isCurved: false,
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
      },
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