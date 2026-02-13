import 'package:flutter/material.dart';
import '../shopping_list.dart';
import '../mock_data.dart';

class ShoppingListScreen extends StatefulWidget {
  final String? initialRecipeId;
  final String? initialSortBy;

  const ShoppingListScreen({
    super.key,
    this.initialRecipeId,
    this.initialSortBy,
  });

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final ShoppingList shoppingList = ShoppingList();
  String selectedSort = 'cost';

  @override
  void initState() {
    super.initState();
    if (widget.initialRecipeId != null && widget.initialSortBy != null) {
      shoppingList.addRecipe(widget.initialRecipeId!, widget.initialSortBy!);
    }
  }

  void _addRecipeToShoppingList(String recipeId) {
    setState(() {
      shoppingList.addRecipe(recipeId, selectedSort);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                selectedSort = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'cost', child: Text('Sort by Cost')),
              const PopupMenuItem(value: 'distance', child: Text('Sort by Distance')),
              const PopupMenuItem(value: 'calories', child: Text('Sort by Calories')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Test Controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: mockRecipes.keys.map((recipeId) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () => _addRecipeToShoppingList(recipeId),
                      child: Text('Add $recipeId'),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: shoppingList.shoppingItems.isEmpty
                ? const Center(
                    child: Text('Your shopping list is empty.'),
                  )
                : ListView.builder(
                    itemCount: shoppingList.shoppingItems.length,
                    itemBuilder: (context, index) {
                      final item = shoppingList.shoppingItems[index];
                      return ListTile(
                        leading: Checkbox(
                          value: false,
                          onChanged: (value) {},
                        ),
                        title: Text(item.name),
                        subtitle: Text(
                          'Cost: £${item.cost.toStringAsFixed(2)} | Dist: ${item.distance}km | Cal: ${item.calories}',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
