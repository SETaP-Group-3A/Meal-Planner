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
                children: mockRecipes.map((recipe) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () => _addRecipeToShoppingList(recipe.id),
                      child: Text('Add ${recipe.name}'),
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
                      final listItem = shoppingList.shoppingItems[index];
                      final ingredient = listItem.ingredient;
                      return ListTile(
                        leading: Checkbox(
                          value: false,
                          onChanged: (value) {},
                        ),
                        title: Text(ingredient.name),
                        subtitle: Text(
                          'Total Cost: \$${listItem.totalCost.toStringAsFixed(2)} | Dist: ${ingredient.distance}km | Cal: ${listItem.totalCalories}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  shoppingList.updateQuantity(index, -1);
                                });
                              },
                            ),
                            Text(
                              '${listItem.quantity}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  shoppingList.updateQuantity(index, 1);
                                });
                              },
                            ),
                          ],
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
