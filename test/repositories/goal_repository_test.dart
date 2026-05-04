
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/weekly_goals.dart';
import 'package:meal_planner/repositories/goal_repository.dart';

void main() {
  group("Goal Repository - Total Amount", () {
    test("Total of empty array", () {
      GoalRepository goalRepository = GoalRepository();

      double total = goalRepository.totalAmount([]);
      expect(total, 0);
    });
    test("Total of populated array", () {
      GoalRepository goalRepository = GoalRepository();

      double total = goalRepository.totalAmount([
        Goal(id: GoalType.money, day: 0, value: 100.0),
        Goal(id: GoalType.money, day: 1, value: 50.0),
        Goal(id: GoalType.money, day: 2, value: 200.0),
      ]);
      expect(total, 350.0);
    });
  });
}