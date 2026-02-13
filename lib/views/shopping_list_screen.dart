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

  @override
  void initState() {
    super.initState();
    if (widget.initialRecipeId != null && widget.initialSortBy != null) {
      shoppingList.addRecipe(widget.initialRecipeId!, widget.initialSortBy!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
      ),
      body: shoppingList.shoppingItems.isEmpty
          ? const Center(
              child: Text('Your shopping list is empty.'),
            )
          : ListView.builder(
              itemCount: shoppingList.shoppingItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: false,
                    onChanged: (value) {},
                  ),
                  title: Text(shoppingList.shoppingItems[index]),
                );
              },
            ),
    );
  }
}
