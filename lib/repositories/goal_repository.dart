import 'package:meal_planner/models/weekly_goals.dart';

class GoalRepository {

  Map<int, List<Goal>> mapGoals(List<Goal> goals) {
    //hardcoded for now
    return {
      0: [
        Goal(id: "save money", day: 0, value: 500),
        Goal(id: "save money", day: 1, value: 20),
        Goal(id: "save money", day: 2, value: 100),
      ],
      1: [
        Goal(id: "save money", day: 0, value: 300),
        Goal(id: "save money", day: 1, value: 50),
      ],
    };

  }

  double totalAmount(List<Goal> goals) {
    //hardcoded for now
    return goals.fold(0, (sum, goal) => sum + goal.value);
  }
}