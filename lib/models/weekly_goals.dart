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

  GoalType currentGoalType = GoalType.money;

  // When a WeeklyGoals instance is created, start loading values from the DB
  WeeklyGoals({String? accountEmail, required GoalType type}) {
    currentGoalType = type;
    try {
      loadFromDatabase(accountEmail: accountEmail, expectedType: type).then((_) {
        // After loading, ensure weeks are up-to-date for this account.
        _maybeAdvanceWeeks(accountEmail);
      });
    } catch (_) {
      // ignore — loadFromDatabase handles its own errors
    }
  }

  /// If the latest stored week's start date is >= 7 days old, create
  /// subsequent empty weeks (persisting them) until the latest week's
  /// start date is within the current 7-day window.
  Future<void> _maybeAdvanceWeeks(String? accountEmail) async {
    if (accountEmail == null) return;

    try {
      final dbSvc = DatabaseService.instance;
      final db = await dbSvc.database;

      // Resolve account id
      final users = await db.query(
        'users',
        columns: ['id'],
        where: 'email = ?',
        whereArgs: [accountEmail],
        limit: 1,
      );
      final accountId = users.isNotEmpty ? users.first['id'] as String? : null;
      if (accountId == null) return;

      // Determine latest week id and its start date from in-memory if available
      int latestWeekId = goals.keys.isNotEmpty ? goals.keys.last : 0;
      DateTime? latestStart = weekStartDates[latestWeekId];

      if (latestStart == null) {
        // nothing to advance from
        return;
      }

      // If the latest stored week's start date is 7+ days ago, create
      final start = latestStart;
      if (DateTime.now().difference(start) >= const Duration(days: 7)) {
        final newWeekId = latestWeekId + 1;

        // Read a single goal_type for the previous week — the week has one
        // goal type for all days, so use that for the new week's entries.
        final typeRow = await db.rawQuery(
          '''
          SELECT g.goal_type
          FROM goal g
          JOIN week_goal wg ON wg.goal_id = g.goal_id
          WHERE wg.account_id = ? AND wg.week_goal_id = ?
          LIMIT 1
        ''',
          [accountId, latestWeekId],
        );

        var weekType = GoalType.money;
        if (typeRow.isNotEmpty) {
          final typeStr = typeRow.first['goal_type']?.toString() ?? 'money';
          weekType = GoalTypes.fromDbString(typeStr);
        }

        final newGoals = List<Goal>.generate(
          7,
          (i) => Goal(id: weekType, day: i, value: 0.0),
        );

        // Persist new goals for this account/week
        final newStart = start.add(const Duration(days: 7));
        for (final goal in newGoals) {
          final createdGoalId = await dbSvc.createGoal(
            goal.id.toString(),
            accountId,
            goal.day,
            goal.value,
          );
          await db.insert('week_goal', {
            'week_goal_id': newWeekId,
            'account_id': accountId,
            'goal_id': createdGoalId,
            'start_date': newStart.toIso8601String(),
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        // Update in-memory state
        goals[newWeekId] = newGoals;
        weekStartDates[newWeekId] = newStart;
      }

      if (goals.isNotEmpty) notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error advancing weeks: $e');
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
      throw ArgumentError(
        'Value out of range: weekID must be non-negative and day must be between 0 and 6',
      );
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

  Future<bool> loadFromDatabase({String? accountEmail, required GoalType expectedType}) async {
    try {
      final db = await DatabaseService.instance.database;

      if (expectedType != currentGoalType) {
        await updateGoalType(newType: expectedType, accountEmail: accountEmail);
      }
      // if caller supplied an email, resolve it to the internal account id
      String? accountId;

      if (accountEmail == null) return false;

      final users = await db.query(
        'users',
        columns: ['id'],
        where: 'email = ?',
        whereArgs: [accountEmail],
        limit: 1,
      );
      accountId = users.isNotEmpty ? users.first['id'] as String? : null;

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

        final type = GoalTypes.fromDbString(goalTypeStr);
        if (type != expectedType) continue;

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

        addGoal(Goal(id: type, day: day, value: goalValue), weekId);
      }

      return goals.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<WeeklyGoals> loadOrFallback({
    String? accountEmail,
    required GoalType requestGoalType
  }) async {

    final instance = WeeklyGoals(accountEmail: accountEmail, type: requestGoalType);
    final ok = await instance.loadFromDatabase(accountEmail: accountEmail, expectedType: requestGoalType);
    if (ok) return instance;

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
          final createdGoalId = await dbSvc.createGoal(
            goal.id.toString(),
            accountId,
            goal.day,
            goal.value,
          );

          if (accountId != null) {
            await db.insert('week_goal', {
              'week_goal_id': weekId,
              'account_id': accountId,
              'goal_id': createdGoalId,
              'start_date':
                  weekStartDates[weekId]?.toIso8601String() ??
                  DateTime.now().toIso8601String(),
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      }
    } catch (e) {
      // Log errors so migrations/schema mismatches are visible during debugging
      // print('WeeklyGoals.saveToDatabase error: $e');
      rethrow;
    }
  }

  /// Persist a single day's goal for a given week and account email.
  /// Resolves `accountEmail` to internal id and updates or creates goal rows.
  Future<void> persistSingleGoal({
    String? accountEmail,
    required int weekId,
    required int day,
    required double value,
    GoalType? id,
  }) async {
    // update in-memory first
    setGoalValue(weekId, day, value, id: id);

    try {
      final dbSvc = DatabaseService.instance;
      final db = await dbSvc.database;

      String? accountId;
      if (accountEmail != null) {
        final users = await db.query(
          'users',
          columns: ['id'],
          where: 'email = ?',
          whereArgs: [accountEmail],
          limit: 1,
        );
        accountId = users.isNotEmpty ? users.first['id'] as String? : null;
      }

      if (accountId == null) {
        // nothing persisted for anonymous/no-account users
        notifyListeners();
        return;
      }

      final existingGoalId = await dbSvc.findGoalIdForWeekAccountDay(
        weekId,
        accountId,
        day,
      );

      if (existingGoalId != null) {
        await dbSvc.updateGoal(existingGoalId, day, value);
      }
    } catch (e) {
      // preserve in-memory change even if DB fails; surface error in debug
      if (kDebugMode) print('persistSingleGoal error: $e');
    }

    notifyListeners();
  }

  static Future<void> registerNewGoals({
    required String accountId,
    required GoalType goalType,
  }) async {
    final weeklyGoals = WeeklyGoals(type: goalType);
    weeklyGoals.goals[0] = List.generate(
      7,
      (index) => Goal(id: goalType, day: index, value: 0.0),
    );
    weeklyGoals.weekStartDates[0] = DateTime.now();
    await weeklyGoals.saveToDatabase(accountId: accountId);
  }

  Future<WeeklyGoals> updateGoalType({
    required GoalType newType,
    String? accountEmail,
  }) async {
    final dbSvc = DatabaseService.instance;
    final db = await dbSvc.database;

    String? accountId;
    if (accountEmail != null) {
      accountId = await dbSvc.resolveAccountIdFromEmail(accountEmail);
    }

    if (accountId != null) {
      final found = await db.rawQuery(
        '''
      SELECT wg.week_goal_id, wg.start_date
      FROM week_goal wg
      JOIN goal g ON g.goal_id = wg.goal_id
      WHERE wg.account_id = ? AND g.goal_type = ?
      ORDER BY wg.week_goal_id DESC
      LIMIT 1
    ''',
        [accountId, newType.toString()],
      );

      if (found.isNotEmpty) {
        final wk = (found.first['week_goal_id'] as num).toInt();
        final startStr = found.first['start_date']?.toString();
        if (startStr != null && startStr.isNotEmpty) {
          final parsed = DateTime.tryParse(startStr);
          if (parsed != null) weekStartDates[wk] = parsed;
        }

        final rows = await db.rawQuery(
          '''
        SELECT g.day_id, g.goal_value
        FROM goal g
        JOIN week_goal wg ON wg.goal_id = g.goal_id
        WHERE wg.account_id = ? AND wg.week_goal_id = ?
        ORDER BY g.day_id ASC
      ''',
          [accountId, wk],
        );

        goals[wk] = rows.map((r) {
          final day = (r['day_id'] as num).toInt();
          final val = (r['goal_value'] as num).toDouble();
          return Goal(id: newType, day: day, value: val);
        }).toList();

        notifyListeners();
        return this;
      }
    }

    final newWeekId = (goals.keys.isNotEmpty ? goals.keys.last + 1 : 0);
    final newStart = DateTime.now();
    final newGoals = List<Goal>.generate(
      7,
      (i) => Goal(id: newType, day: i, value: 0.0),
    );

    if (accountId != null) {
      for (final goal in newGoals) {
        final createdGoalId = await dbSvc.createGoal(
          goal.id.toString(),
          accountId,
          goal.day,
          goal.value,
        );
        await db.insert('week_goal', {
          'week_goal_id': newWeekId,
          'account_id': accountId,
          'goal_id': createdGoalId,
          'start_date': newStart.toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }

    currentGoalType = newType;
    goals[newWeekId] = newGoals;
    weekStartDates[newWeekId] = newStart;
    notifyListeners();
    return this;
  }
}

class Goal {
  final GoalType id;
  final int day;
  double value;

  Goal({required this.id, required this.day, required this.value});
}
