import 'package:flutter/material.dart';
import 'package:meal_planner/models/weekly_goals.dart';
import 'package:meal_planner/repositories/goal_repository.dart';

class GoalDiaryScreen extends StatefulWidget {

  final List<WeeklyGoals> weeklyGoals;

  const GoalDiaryScreen({super.key, required this.weeklyGoals});

  @override
  State<GoalDiaryScreen> createState() => _GoalDiaryScreenState();
}

class _GoalDiaryScreenState extends State<GoalDiaryScreen> {

  final GoalRepository repository = GoalRepository();

  List<Goal> currentGoals = [];

  @override
  Widget build(BuildContext context) {
    final int? lastKey = (widget.weeklyGoals.isNotEmpty && widget.weeklyGoals[0].goals.isNotEmpty)
      ? widget.weeklyGoals[0].goals.keys.last
      : null;
    currentGoals = lastKey != null
      ? widget.weeklyGoals[0].goals[lastKey] ?? <Goal>[]
      : <Goal>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Diary'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text('Diary', style: Theme.of(context).textTheme.headlineLarge)),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text('Total: ${repository.totalAmount(currentGoals)}'), SizedBox(width: 8), Text('Savings:')],
                ),
              ),
              Container(height: 16),
              // Render seven DayGoalWidget items from the list at the last key
              for (int i = 0; i < 7; i++)
                DayGoalWidget(
                  day: 'Day ${i + 1}',
                  goal: (() {
                    for (final g in currentGoals) {
                      if (g.day == i) return g.value.toString();
                    }
                    return '';
                  })(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DayGoalWidget extends StatefulWidget {
  final String day;
  final String goal;

  const DayGoalWidget({super.key, required this.day, required this.goal});

  @override
  State<DayGoalWidget> createState() => _DayGoalWidgetState();
}

class _DayGoalWidgetState extends State<DayGoalWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.goal);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Text(widget.day),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                controller: _controller,
                onChanged: (value) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}