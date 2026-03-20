import 'package:flutter/material.dart';
import 'package:meal_planner/models/weekly_goals.dart';
import 'package:meal_planner/repositories/goal_repository.dart';

class GoalDiaryScreen extends StatefulWidget {

  const GoalDiaryScreen({super.key});

  @override
  State<GoalDiaryScreen> createState() => _GoalDiaryScreenState();
}

class _GoalDiaryScreenState extends State<GoalDiaryScreen> {

  final GoalRepository repository = GoalRepository();
  final List<WeeklyGoals> weeklyGoals = [];

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
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Total:'),
                SizedBox(width: 8),
                Text('Savings:')
              ],
            ),
            Container(height: 16),
            for (WeeklyGoals wg in weeklyGoals)
              for (final goalsForWeek in wg.goals.values)
                for (final goalItem in goalsForWeek)
                  DayGoalWidget(
                    day: 'Day ${goalItem.day + 1}',
                    goal: goalItem.value.toString(),
                  ),
          ],
        ),
      ),
    );
  }
}

class DayGoalWidget extends StatelessWidget {
  final String day;
  final String goal;

  const DayGoalWidget({super.key, required this.day, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(day),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              controller: TextEditingController(text: goal),
              onChanged: (value) => {},
            ),
          ),
        ],
      )
    );
  }
}