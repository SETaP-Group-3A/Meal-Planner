import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/weekly_goals.dart';

void main() {
  group("WeeklyGoals - Correctly add and set new goals", () {
    test("Add and set goal", () {
      WeeklyGoals wg = WeeklyGoals();
      wg.addGoal(Goal(id: GoalType.money, day: 0, value: 100.0), 0);
      wg.setGoalValue(0, 0, 150.0);
      expect(wg.goals[0]![0].value, 150.0);
    });

    test("Multiple goals", () {
      WeeklyGoals wg = WeeklyGoals();
      wg.addGoal(Goal(id: GoalType.money, day: 0, value: 100.0), 0);
      wg.addGoal(Goal(id: GoalType.money, day: 1, value: 50.0), 0);
      wg.addGoal(Goal(id: GoalType.money, day: 2, value: 200.0), 0);
      wg.setGoalValue(0, 1, 75.0);
      expect(wg.goals[0]![1].value, 75.0);
    });

    test("Invalid week ID", () {
      WeeklyGoals wg = WeeklyGoals();
      expect(() => wg.addGoal(Goal(id: GoalType.money, day: 0, value: 100.0), -1), throwsArgumentError);
    });

    test("Invalid day", () {
      WeeklyGoals wg = WeeklyGoals();
      expect(() => wg.setGoalValue(0, -1, 100.0), throwsArgumentError);
      expect(() => wg.setGoalValue(0, 7, 100.0), throwsArgumentError);
    });
  });
}