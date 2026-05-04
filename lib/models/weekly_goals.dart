import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:meal_planner/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

enum GoalType { money, calories, distance }

class GoalTypes { 
  static GoalType fromString(String s) {
    switch (s) {
      case 'money':
        return GoalType.money;
      case 'calories':
        return GoalType.calories;
      case 'distance':
        return GoalType.distance;
      default:
        throw ArgumentError('Unknown goal type: $s');
    }
  }

  /// Parse values that may come from the DB. Some code stores the enum
  /// via `goal.id.toString()` which produces `GoalType.money`.
  static GoalType fromDbString(String s) {
    if (s.startsWith('GoalType.')) {
      return fromString(s.split('.').last);
    }
    return fromString(s);
  }

  static String displayGoal(GoalType type, String value) {
    switch (type) {
      case GoalType.money:
        if (double.tryParse(value)! < 0) {
          return '-£${value.substring(1)}'; // remove decimal if it's a whole number
        }
        return '£$value';
      case GoalType.calories:
        return '$value cal';
      case GoalType.distance:
        return '$value km';
    }
  }

  static double parseValue(GoalType type, String s) {
    switch (type) {
      case GoalType.money:
        return double.tryParse(s.replaceAll('£', '')) ?? 0;
      case GoalType.calories:
        return double.tryParse(s.replaceAll(' cal', '')) ?? 0;
      case GoalType.distance:
        return double.tryParse(s.replaceAll(' km', '')) ?? 0;
    }
  }
}

class WeeklyGoals extends ChangeNotifier {
  Map<int, List<Goal>> goals = {};
  // store start date for each week id
  Map<int, DateTime> weekStartDates = {};

  // When a WeeklyGoals instance is created, start loading values from the DB
  WeeklyGoals({String? accountEmail}) {
    // fire-and-forget; loadFromDatabase will populate and notify listeners
    try {
      loadFromDatabase(accountEmail: accountEmail);
    } catch (_) {
      // ignore — loadFromDatabase handles its own errors
    }
  }

  void addGoal(Goal goal, int weekID) {
    if (weekID < 0) {
      throw ArgumentError('Week ID must be non-negative');
    }

    if (!goals.containsKey(weekID)) {
      goals[weekID] = [];
    }
    goals[weekID]!.add(goal);
    notifyListeners();
  }

  void setGoalValue(int weekID, int day, double value, {GoalType? id}) {

    if (weekID < 0 || day < 0 || day > 6) {
      throw ArgumentError('Value out of range: weekID must be non-negative and day must be between 0 and 6');
    }

    if (!goals.containsKey(weekID)) goals[weekID] = [];
    final list = goals[weekID]!;
    final idx = list.indexWhere((g) => g.day == day);
    if (idx == -1) {
      // insert at correct position to keep list ordered by day
      final newGoal = Goal(id: id ?? GoalType.money, day: day, value: value);
      final insertAt = list.indexWhere((g) => g.day > day);
      if (insertAt == -1) {
        list.add(newGoal);
      } else {
        list.insert(insertAt, newGoal);
      }
    } else {
      list[idx].value = value;
      if (id != null) {
        // set id if it was empty
        list[idx] = Goal(id: id, day: list[idx].day, value: list[idx].value);
      }
    }
    notifyListeners();
  }

  List<Goal> getGoalsForCurrentWeek() {
    return getGoalsForWeek(goals.keys.isNotEmpty ? goals.keys.last : 0);
  }

  List<Goal> getGoalsForWeek(int weekID) {
    return goals[weekID] ?? [];
  }

  int get currentWeek => goals.keys.isNotEmpty ? goals.keys.last : 0;

  Future<bool> loadFromDatabase({String? accountEmail}) async {
    try {
      final db = await DatabaseService.instance.database;

      // if caller supplied an email, resolve it to the internal account id
      String? accountId;
      if (accountEmail != null) {
        final users = await db.query('users', columns: ['id'], where: 'email = ?', whereArgs: [accountEmail], limit: 1);
        accountId = users.isNotEmpty ? users.first['id'] as String? : null;
      }

      // Join goal with week_goal so we can associate goals with weeks/accounts
      final rows = await db.rawQuery('''
        SELECT g.goal_id, g.goal_type, g.day_id, g.goal_value, wg.week_goal_id, wg.start_date
        FROM goal g
        LEFT JOIN week_goal wg ON wg.goal_id = g.goal_id
        ${accountId != null ? 'WHERE wg.account_id = ?' : ''}
      ''', accountId != null ? [accountId] : null);

      if (rows.isEmpty) return false;

      for (final row in rows) {
        final goalTypeStr = row['goal_type']?.toString() ?? 'money';
        final day = (row['day_id'] as int?) ?? 0;
        final goalValue = (row['goal_value'] as num?)?.toDouble() ?? 0.0;
        final weekId = (row['week_goal_id'] as int?) ?? 0;
        final startDateStr = row['start_date']?.toString();
        if (startDateStr != null && startDateStr.isNotEmpty) {
          try {
            final parsed = DateTime.tryParse(startDateStr);
            if (parsed != null) weekStartDates[weekId] = parsed;
          } catch (_) {}
        }

        final type = GoalTypes.fromDbString(goalTypeStr);
        addGoal(Goal(id: type, day: day, value: goalValue), weekId);
      }

      return goals.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<WeeklyGoals> loadOrFallback({String? accountEmail, WeeklyGoals? fallback}) async {
    final instance = WeeklyGoals(accountEmail: accountEmail);
    final ok = await instance.loadFromDatabase(accountEmail: accountEmail);
    if (ok) return instance;

    if (fallback != null && fallback.goals.isNotEmpty) {
      instance.goals = Map<int, List<Goal>>.from(fallback.goals);
      return instance;
    }

    //Temp fallback while account system is being implemented
    instance.goals[0] = [
      Goal(id: GoalType.money, day: 0, value: 200.0),
      Goal(id: GoalType.money, day: 2, value: 50.0),
    ];
    instance.goals[1] = [
      Goal(id: GoalType.money, day: 0, value: 500.0),
      Goal(id: GoalType.money, day: 1, value: 150.0),
    ];

    return instance;
  }

  //Not actually called yet
  Future<void> saveToDatabase({String? accountId}) async {
    try {
      final dbSvc = DatabaseService.instance;
      final db = await dbSvc.database;

      for (var entry in goals.entries) {
        final weekId = entry.key;
        final goalsForWeek = entry.value;

        for (var goal in goalsForWeek) {
          // createGoal now returns the autoincremented goal row id
          final createdGoalId = await dbSvc.createGoal(goal.id.toString(), accountId, goal.day, goal.value);

          if (accountId != null) {
            await db.insert(
              'week_goal',
              {
                'week_goal_id': weekId,
                'account_id': accountId,
                'goal_id': createdGoalId,
                'start_date': weekStartDates[weekId]?.toIso8601String() ?? DateTime.now().toIso8601String(),
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      }
    } catch (e) {
      // Log errors so migrations/schema mismatches are visible during debugging
      // print('WeeklyGoals.saveToDatabase error: $e');
      rethrow;
    }
  }

  static Future<void> registerNewGoals({required String accountId, GoalType? goalType}) async {
    final weeklyGoals = WeeklyGoals();
    weeklyGoals.goals[0] = List.generate(7, (index) => Goal(id: goalType ?? GoalType.money, day: index, value: 0.0));
    weeklyGoals.weekStartDates[0] = DateTime.now();
    await weeklyGoals.saveToDatabase(accountId: accountId);
  }

}
class Goal {
  final GoalType id;
  final int day;
  double value;

  Goal({required this.id, required this.day, required this.value}); 
}
