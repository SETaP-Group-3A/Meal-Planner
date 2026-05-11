import 'package:meal_planner/models/weekly_goals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphController {

  List<Goal> userData;

  GraphController([this.userData = const []]) {
    updateGraph(userData.isNotEmpty ? userData[0].id : GoalType.money);
  }

  Future<List<Goal>> fetchLatestWeekGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final accountEmail = prefs.getString('accountEmail');
    if (accountEmail == null) return [];

    final goal = prefs.getString('goal') ?? 'money';
    final GoalType type = GoalTypes.fromDbString(goal);

    final weekly = await WeeklyGoals.loadOrFallback(
      accountEmail: accountEmail,
      requestGoalType: type,
    );

    return weekly.getGoalsForCurrentWeek();
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