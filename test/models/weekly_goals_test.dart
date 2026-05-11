import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/weekly_goals.dart';

void main() {
  group ("WeeklyGoals - Can parse goal value between display and actual value", () {
    test("Money goal", () {
      expect(GoalTypes.parseValue(GoalType.money, '£100'), 100.0);
      expect(GoalTypes.parseValue(GoalType.money, '-£50'), -50.0);
    });

    test("Calories goal", () {
      expect(GoalTypes.parseValue(GoalType.calories, '200 cal'), 200.0);
    });

    test("Distance goal", () {
      expect(GoalTypes.parseValue(GoalType.distance, '5 km'), 5.0);
    });
  });
  group("WeeklyGoals - Correctly add and set new goals", () {
    test("Add and set goal", () {
      WeeklyGoals wg = WeeklyGoals(type: GoalType.money);
      wg.addGoal(Goal(id: GoalType.money, day: 0, value: 100.0), 0);
      wg.setGoalValue(0, 0, 150.0);
      expect(wg.goals[0]![0].value, 150.0);
    });

    test("Multiple goals", () {
      WeeklyGoals wg = WeeklyGoals(type: GoalType.money);
      wg.addGoal(Goal(id: GoalType.money, day: 0, value: 100.0), 0);
      wg.addGoal(Goal(id: GoalType.money, day: 1, value: 50.0), 0);
      wg.addGoal(Goal(id: GoalType.money, day: 2, value: 200.0), 0);
      wg.setGoalValue(0, 1, 75.0);
      expect(wg.goals[0]![1].value, 75.0);
    });

    test("Invalid week ID", () {
      WeeklyGoals wg = WeeklyGoals(type: GoalType.money);
      expect(() => wg.addGoal(Goal(id: GoalType.money, day: 0, value: 100.0), -1), throwsArgumentError);
    });

    test("Invalid day", () {
      WeeklyGoals wg = WeeklyGoals(type: GoalType.money);
      expect(() => wg.setGoalValue(0, -1, 100.0), throwsArgumentError);
      expect(() => wg.setGoalValue(0, 7, 100.0), throwsArgumentError);
    });
  });
}