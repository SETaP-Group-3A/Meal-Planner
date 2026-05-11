import 'package:flutter/material.dart';
import '../shopping_list.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeShoppingList();
  }

  Future<void> _initializeShoppingList() async {
    setState(() => _isLoading = true);
    await shoppingList.initialize();

    if (widget.initialRecipeId != null && widget.initialSortBy != null) {
      selectedSort = widget.initialSortBy!;
      await shoppingList.addRecipe(widget.initialRecipeId!, widget.initialSortBy!);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Widget _buildFocusButton(String label, String value, IconData icon) {
    final isSelected = selectedSort == value;
    return ElevatedButton.icon(
      onPressed: () => _regenerateList(value),
      icon: Icon(icon, color: isSelected ? Colors.white : null),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).primaryColor : null,
        foregroundColor: isSelected ? Colors.white : null,
      ),
    );
  }

  Future<void> _regenerateList(String newSort) async {
    setState(() => _isLoading = true);
    await shoppingList.regenerateList(newSort);
    if (mounted) {
      setState(() {
        selectedSort = newSort;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
      ),
      body: Column(
        children: [
          // Focus Selection Buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFocusButton('Cost', 'cost', Icons.attach_money),
                _buildFocusButton('Distance', 'distance', Icons.location_on),
                _buildFocusButton('Health', 'calories', Icons.favorite),
              ],
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : shoppingList.shoppingItems.isEmpty
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
                          'Total Cost: £${listItem.totalCost.toStringAsFixed(2)} | Dist: ${ingredient.distance}km | Cal: ${listItem.totalCalories}',
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
