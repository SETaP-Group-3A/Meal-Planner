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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Diary'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Diary', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Total:'),
                SizedBox(width: 8),
                Text('Savings:')
              ],
            ),
            Container(height: 16),
            for (WeeklyGoals wg in widget.weeklyGoals)
              for (final goalsForWeek in wg.goals.values)
                for (final goalItem in goalsForWeek)
                  DayGoalWidget(
                    day: 'Day ${goalItem.day + 1}',
                    goal: goalItem.value.toString(),
                  ),
            Text("Beneath DayGoalWidgets")
          ],
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