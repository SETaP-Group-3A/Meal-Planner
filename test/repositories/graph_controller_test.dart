import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/weekly_goals.dart';
import 'package:meal_planner/repositories/graph_controller.dart';

void main() {
  group("GraphController - Correctly creates y axis points", () {
    test("Empty goals", () {
      GraphController controller = GraphController([]);
      List<int> yAxisPoints = controller.updateGraph(GoalType.money);
      expect(yAxisPoints, [0, 0, 0, 0, 0, 0, 0]);
    });
    test("Money goals", () {
    GraphController controller = GraphController([
      Goal(id: GoalType.money, day: 0, value: 100.0),
      Goal(id: GoalType.money, day: 1, value: 50.0),
      Goal(id: GoalType.money, day: 2, value: 200.0),
    ]);

    List<int> yAxisPoints = controller.updateGraph(GoalType.money);
    expect(yAxisPoints, [100.0, 50.0, 200.0, 0, 0, 0, 0]);
    });

    test("Incorrect Combination of goals", () {
      GraphController controller = GraphController([
        Goal(id: GoalType.money, day: 0, value: 100.0),
        Goal(id: GoalType.calories, day: 1, value: 50.0),
        Goal(id: GoalType.distance, day: 2, value: 200.0),
      ]);

      List<int> yAxisPoints = controller.updateGraph(GoalType.money);
      expect(yAxisPoints, [100.0, 0, 0, 0, 0, 0, 0]);
    });

    test("Full week", () {
      GraphController controller = GraphController([
        Goal(id: GoalType.money, day: 0, value: 100.0),
        Goal(id: GoalType.money, day: 1, value: 50.0),
        Goal(id: GoalType.money, day: 2, value: 200.0),
        Goal(id: GoalType.money, day: 3, value: 150.0),
        Goal(id: GoalType.money, day: 4, value: 75.0),
        Goal(id: GoalType.money, day: 5, value: 125.0),
        Goal(id: GoalType.money, day: 6, value: 175.0),
      ]);

      List<int> yAxisPoints = controller.updateGraph(GoalType.money);
      expect(yAxisPoints, [100.0, 50.0, 200.0, 150.0, 75.0, 125.0, 175.0]);
    });
  });
}