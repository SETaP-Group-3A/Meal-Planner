import 'package:meal_planner/models/weekly_goals.dart';
import 'package:meal_planner/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphController {

  List<Goal> userData;

  GraphController([this.userData = const []]) {
    updateGraph(userData.isNotEmpty ? userData[0].id : GoalType.money);
  }

  /// Fetch the latest week's goals for the currently-saved account email
  /// (reads `accountEmail` from SharedPreferences). Returns an empty list
  /// if no account or no goals exist.
  Future<List<Goal>> fetchLatestWeekGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final accountEmail = prefs.getString('accountEmail');
    if (accountEmail == null) return [];

    final db = await DatabaseService.instance.database;
    final users = await db.query('users', columns: ['id'], where: 'email = ?', whereArgs: [accountEmail], limit: 1);
    final accountId = users.isNotEmpty ? users.first['id'] as String? : null;
    if (accountId == null) return [];

    final maxRow = await db.rawQuery('SELECT MAX(week_goal_id) as wk FROM week_goal WHERE account_id = ?', [accountId]);
    if (maxRow.isEmpty) return [];
    final maxVal = maxRow.first['wk'];
    if (maxVal == null) return [];
    final latestWeekId = maxVal is int ? maxVal : int.tryParse(maxVal.toString());
    if (latestWeekId == null) return [];

    final rows = await db.rawQuery('''
      SELECT g.goal_type, g.day_id, g.goal_value
      FROM goal g
      JOIN week_goal wg ON wg.goal_id = g.goal_id
      WHERE wg.account_id = ? AND wg.week_goal_id = ?
      ORDER BY g.day_id ASC
    ''', [accountId, latestWeekId]);

    final result = <Goal>[];
    for (final row in rows) {
      final typeStr = row['goal_type']?.toString() ?? 'money';
      final day = (row['day_id'] as int?) ?? 0;
      final value = (row['goal_value'] as num?)?.toDouble() ?? 0.0;
      final type = GoalTypes.fromDbString(typeStr);
      result.add(Goal(id: type, day: day, value: value));
    }
    return result;
  }

  List<int> updateGraph(GoalType goal) {
    final result = List<int>.filled(7, 0);
    if (userData.isEmpty) return result;
    for (final g in userData) {
      if (g.id == goal && g.day >= 0 && g.day < 7) result[g.day] = g.value.toInt();
    }
    return result;
  }
}