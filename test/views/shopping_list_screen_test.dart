import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meal_planner/models/ingredient.dart';
import 'package:meal_planner/models/shopping_list_item.dart';
import 'package:meal_planner/shopping_list.dart';
import 'package:meal_planner/views/shopping_list_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
	SharedPreferences.setMockInitialValues({});
	final shoppingList = ShoppingList();

	Future<void> pumpScreen(WidgetTester tester) async {
		await tester.pumpWidget(
			const MaterialApp(
				home: ShoppingListScreen(),
			),
		);
		await tester.pumpAndSettle();
	}

	setUp(() {
		shoppingList.shoppingItems.clear();
	});

	tearDown(() {
		shoppingList.shoppingItems.clear();
	});

	testWidgets('renders app bar title and focus buttons', (tester) async {
		await pumpScreen(tester);

		expect(find.text('Shopping List'), findsOneWidget);
		expect(find.text('Cost'), findsOneWidget);
		expect(find.text('Distance'), findsOneWidget);
		expect(find.text('Health'), findsOneWidget);
	});

	testWidgets('shows empty message when list has no items', (tester) async {
		await pumpScreen(tester);

		expect(find.text('Your shopping list is empty.'), findsOneWidget);
	});

	testWidgets('shows shopping item when list is preloaded', (tester) async {
		shoppingList.shoppingItems.add(
			ShoppingListItem(
				ingredient: Ingredient(
					name: 'Flour (Aldi)',
					cost: 0.80,
					distance: 3.0,
					calories: 360,
				),
			),
		);

		await pumpScreen(tester);

		expect(find.text('Flour (Aldi)'), findsOneWidget);
		expect(find.text('1'), findsOneWidget);
		expect(find.text('Your shopping list is empty.'), findsNothing);
	});

	testWidgets('pressing plus increments quantity', (tester) async {
		shoppingList.shoppingItems.add(
			ShoppingListItem(
				ingredient: Ingredient(
					name: 'Flour (Aldi)',
					cost: 0.80,
					distance: 3.0,
					calories: 360,
				),
			),
		);

		await pumpScreen(tester);

		await tester.tap(find.byIcon(Icons.add));
		await tester.pumpAndSettle();

		expect(find.text('2'), findsOneWidget);
		expect(shoppingList.shoppingItems.first.quantity, 2);
	});

	testWidgets('tapping minus decreases quantity', (tester) async {
		shoppingList.shoppingItems.add(
			ShoppingListItem(
				ingredient: Ingredient(
					name: 'Flour (Aldi)',
					cost: 0.80,
					distance: 3.0,
					calories: 360,
				),
				quantity: 2,
			),
		);

		await pumpScreen(tester);

		await tester.tap(find.byIcon(Icons.remove));
		await tester.pumpAndSettle();

		expect(find.text('1'), findsOneWidget);
		expect(shoppingList.shoppingItems.first.quantity, 1);
	});

	testWidgets('item is removed when quantity reaches zero', (tester) async {
		shoppingList.shoppingItems.add(
			ShoppingListItem(
				ingredient: Ingredient(
					name: 'Flour (Aldi)',
					cost: 0.80,
					distance: 3.0,
					calories: 360,
				),
			),
		);

		await pumpScreen(tester);

		await tester.tap(find.byIcon(Icons.remove));
		await tester.pumpAndSettle();

		expect(find.text('Flour (Aldi)'), findsNothing);
		expect(find.text('Your shopping list is empty.'), findsOneWidget);
		expect(shoppingList.shoppingItems, isEmpty);
	});
}
