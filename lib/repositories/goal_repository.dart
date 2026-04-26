import 'package:meal_planner/models/weekly_goals.dart';

class GoalRepository {
  
  double totalAmount(List<Goal> goals) {
    //hardcoded for now
    return goals.fold(0, (sum, goal) => sum + goal.value);
  }

  double calculateSavings(List<Goal> goals, List<Goal> lastWeekGoals) {
    //No last week
    if (lastWeekGoals.isEmpty) {
      return 0;
    }

    return totalAmount(lastWeekGoals) - totalAmount(goals);
  }
}