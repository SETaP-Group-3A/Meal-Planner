import 'package:flutter/material.dart';
import 'package:meal_planner/models/weekly_goals.dart';
import 'package:provider/provider.dart';
import 'package:meal_planner/repositories/goal_repository.dart';
import 'package:meal_planner/views/app_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_planner/services/database_service.dart';
import 'package:sqflite/sql.dart';

class GoalDiaryScreen extends StatefulWidget {

  final int dayIndex;

  const GoalDiaryScreen({super.key, this.dayIndex = -1});

  @override
  State<GoalDiaryScreen> createState() => _GoalDiaryScreenState();
}

class _GoalDiaryScreenState extends State<GoalDiaryScreen> {

  final GoalRepository repository = GoalRepository();

  GoalType selectedGoalType = GoalType.money;

  List<Goal> currentGoals = [];

  Future<void> updateGoal(int day, double value) async {
    final weekly = Provider.of<WeeklyGoals>(context, listen: false);
    final weekId = weekly.currentWeek;
    weekly.setGoalValue(weekId, day, value, id: GoalType.money);

    // persist change for this single day
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountEmail = prefs.getString('accountEmail');
      if (accountEmail == null) {
        setState(() { currentGoals = weekly.getGoalsForCurrentWeek(); });
        return;
      }

      final db = await DatabaseService.instance.database;
      final users = await db.query('users', columns: ['id'], where: 'email = ?', whereArgs: [accountEmail], limit: 1);
      final accountId = users.isNotEmpty ? users.first['id'] as String? : null;
      if (accountId == null) {
        setState(() { currentGoals = weekly.getGoalsForCurrentWeek(); });
        return;
      }

      final dbSvc = DatabaseService.instance;
      final existingGoalId = await dbSvc.findGoalIdForWeekAccountDay(weekId, accountId, day);

      if (existingGoalId != null) {
        await dbSvc.updateGoal(existingGoalId, day, value);
      } else {
        // create goal row and mapping
        final goalType = (weekly.getGoalsForWeek(weekId).firstWhere((g) => g.day == day, orElse: () => Goal(id: GoalType.money, day: day, value: value))).id.toString();
        final createdGoalId = await dbSvc.createGoal(goalType, accountId, day, value);
        await db.insert(
          'week_goal',
          {
            'week_goal_id': weekId,
            'account_id': accountId,
            'goal_id': createdGoalId,
            'start_date': weekly.weekStartDates[weekId]?.toIso8601String() ?? DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      print('Error saving goal update: $e');
    }

      // persist change for this single day via the model
      try {
        final prefs = await SharedPreferences.getInstance();
        final accountEmail = prefs.getString('accountEmail');
        await weekly.persistSingleGoal(accountEmail: accountEmail, weekId: weekId, day: day, value: value, id: GoalType.money);
      } catch (e) {
        print('Error saving goal update: $e');
      }

      setState(() { currentGoals = weekly.getGoalsForCurrentWeek(); });
  }

  @override
  Widget build(BuildContext context) {
    final WeeklyGoals weekSource = Provider.of<WeeklyGoals>(context);
    currentGoals = weekSource.getGoalsForCurrentWeek();

    selectedGoalType = currentGoals.isNotEmpty ? currentGoals[0].id : GoalType.money;

    final List<Goal> lastWeekGoals = () {
      if (weekSource.goals.keys.length < 2) return <Goal>[];
      final lastKey = weekSource.goals.keys.last;
      return weekSource.getGoalsForWeek(lastKey - 1);
    }();

    final int savings = repository.calculateSavings(currentGoals, lastWeekGoals).toInt();

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
              const SizedBox(height: 8),
              Center(child: Text('Week ${weekSource.currentWeek}', style: AppStyles.subtitleText)),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [Text('Total: ${GoalTypes.displayGoal(selectedGoalType, repository.totalAmount(currentGoals).toString())}'), SizedBox(width: 16), Text('Savings: ${GoalTypes.displayGoal(selectedGoalType, savings.toString())}', style: AppStyles.hightlightSwitch(savings))],
                ),
              ),
              Container(height: 16),
              // Render seven DayGoalWidget items for each day of the week
              for (int i = 0; i < 7; i++)
                DayGoalWidget(
                  day: 'Day ${i + 1}',
                  dayIndex: i,
                  selectedDayIndex: widget.dayIndex,
                  goal: currentGoals
                      .firstWhere(
                        (g) => g.day == i,
                        orElse: () => Goal(id: GoalType.money, day: i, value: 0),
                      ),
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
  final Goal goal;
  final int dayIndex;
  final int selectedDayIndex;

  final Function(int, double)? onGoalChanged;

  const DayGoalWidget({super.key, required this.day, required this.goal, required this.dayIndex, required this.selectedDayIndex, this.onGoalChanged});

  @override
  State<DayGoalWidget> createState() => _DayGoalWidgetState();
}

class _DayGoalWidgetState extends State<DayGoalWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: GoalTypes.displayGoal(widget.goal.id, widget.goal.value.toString()));
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
      color: widget.dayIndex == widget.selectedDayIndex ? Theme.of(context).colorScheme.primary : null,
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
                  widget.onGoalChanged?.call(widget.dayIndex, GoalTypes.parseValue(widget.goal.id, value));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}