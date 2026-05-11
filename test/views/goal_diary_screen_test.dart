import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/weekly_goals.dart';

import 'package:meal_planner/views/goal_diary_screen.dart';
import 'package:provider/provider.dart';

void main() {
	Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<WeeklyGoals>(
        create: (_) => WeeklyGoals(type: GoalType.money),
        child: const MaterialApp(home: GoalDiaryScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

	testWidgets('diary displays all 7 days', (tester) async {
		await pumpScreen(tester);

    expect(find.byType(DayGoalWidget), findsExactly(7));
	});

  testWidgets('correct diary day is highlighted', (tester) async {
		await tester.pumpWidget(
      ChangeNotifierProvider<WeeklyGoals>(
        create: (_) => WeeklyGoals(type: GoalType.money),
        child: const MaterialApp(home: GoalDiaryScreen(dayIndex: 2)),
      ),
    );

    final dayFinder = find.byWidgetPredicate((widget) => widget is DayGoalWidget && widget.dayIndex == 2);
    expect(dayFinder, findsOneWidget);

    final cardFinder = find.descendant(of: dayFinder, matching: find.byType(Card));
    expect(cardFinder, findsOneWidget);

    final Card card = tester.widget<Card>(cardFinder);
    final primary = Theme.of(tester.element(dayFinder)).colorScheme.primary;
    expect(card.color, equals(primary));
	});
}
