import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/weekly_goals.dart';

import 'package:meal_planner/views/goal_diary_screen.dart';
import 'package:provider/provider.dart';

void main() {
	Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<WeeklyGoals>(
        create: (_) => WeeklyGoals(),
        child: const MaterialApp(home: GoalDiaryScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

	testWidgets('diary displays all 7 days', (tester) async {
		await pumpScreen(tester);

    expect(find.byType(DayGoalWidget), findsExactly(7));
	});
}
