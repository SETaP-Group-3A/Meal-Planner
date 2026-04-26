import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meal_planner/models/ingredient.dart';
import 'package:meal_planner/models/shopping_list_item.dart';
import 'package:meal_planner/shopping_list.dart';
import 'package:meal_planner/views/shopping_list_screen.dart';

void main() {
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
}
