import 'package:flutter/material.dart';
import 'package:meal_planner/models/weekly_goals.dart';
import 'package:meal_planner/repositories/goal_repository.dart';
import 'package:meal_planner/views/app_styles.dart';

class GoalDiaryScreen extends StatefulWidget {

  final List<WeeklyGoals> weeklyGoals;

  const GoalDiaryScreen({super.key, required this.weeklyGoals});

  @override
  State<GoalDiaryScreen> createState() => _GoalDiaryScreenState();
}

class _GoalDiaryScreenState extends State<GoalDiaryScreen> {

  final GoalRepository repository = GoalRepository();

  List<Goal> currentGoals = [];

  void updateGoal(int day, String value) {
    //Update the goal for the given day with the new value
    setState(() {
      final goal = currentGoals.firstWhere((g) => g.day == day, orElse: () => Goal(id: '', day: day, value: 0));
      if (goal.id.isEmpty) {
        // If no existing goal, add a new one
        currentGoals.add(Goal(id: 'save money', day: day, value: double.tryParse(value) ?? 0));
      } else {
        // Update existing goal
        goal.value = double.tryParse(value) ?? 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    currentGoals = widget.weeklyGoals[0].getGoalsForCurrentWeek();

    final List<Goal> lastWeekGoals = widget.weeklyGoals.length > 1 ? widget.weeklyGoals[0].getGoalsForWeek(widget.weeklyGoals[0].goals.keys.last - 1) : [];

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
              Center(child: Text('Diary', style: AppStyles.titleText)),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [Text('Total: ${repository.totalAmount(currentGoals)}', style: AppStyles.subtitleText), SizedBox(width: 16), Text('Savings: ${repository.calculateSavings(currentGoals, lastWeekGoals)}', style: AppStyles.subtitleText)],
                ),
              ),
              Container(height: 16),
              // Render seven DayGoalWidget items for each day of the week
              for (int i = 0; i < 7; i++)
                DayGoalWidget(
                  day: 'Day ${i + 1}',
                  dayIndex: i,
                  goal: currentGoals
                      .firstWhere(
                        (g) => g.day == i,
                        orElse: () => Goal(id: '', day: i, value: 0),
                      )
                      .value
                      .toString(),
                  onGoalChanged: (day, value) => updateGoal(day, value),
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
  final int dayIndex;

  final Function(int, String)? onGoalChanged;

  const DayGoalWidget({super.key, required this.day, required this.goal, required this.dayIndex, this.onGoalChanged});

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
                onChanged: (value) {
                  widget.onGoalChanged?.call(widget.dayIndex, value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}