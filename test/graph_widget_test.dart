
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/graph_widget.dart';
import 'package:meal_planner/models/weekly_goals.dart';

void main() {
    testWidgets("Display empty graph", (WidgetTester tester) async {
      
      await tester.pumpWidget(MaterialApp(home: ProgressGraphWidget(userData: [])));

      expect(find.byType(ProgressGraphWidget), findsOneWidget);
    });
    testWidgets("Display graph with some points", (WidgetTester tester) async {
      
      await tester.pumpWidget(MaterialApp(home: ProgressGraphWidget(userData: [
        Goal(id: GoalType.money, day: 0, value: 100.0),
        Goal(id: GoalType.money, day: 1, value: 50.0),
        Goal(id: GoalType.money, day: 2, value: 200.0),
      ])));

      expect(find.byType(ProgressGraphWidget), findsOneWidget);
    });
    testWidgets("Display graph with all points", (WidgetTester tester) async {
      
      await tester.pumpWidget(MaterialApp(home: ProgressGraphWidget(userData: [
        Goal(id: GoalType.money, day: 0, value: 100.0),
        Goal(id: GoalType.money, day: 1, value: 50.0),
        Goal(id: GoalType.money, day: 2, value: 200.0),
        Goal(id: GoalType.money, day: 3, value: 150.0),
        Goal(id: GoalType.money, day: 4, value: 75.0),
        Goal(id: GoalType.money, day: 5, value: 125.0),
        Goal(id: GoalType.money, day: 6, value: 175.0),
      ])));

      expect(find.byType(ProgressGraphWidget), findsOneWidget);
    });
}