import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../mock_data.dart';
import '../services/database_service.dart';

/// form screen for adding a custom recipe
class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _nameCtrl = TextEditingController();
  final _prepTimeCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  bool _saving = false;
  List<String> _searchResults = [];
  // generic name -> quantity in grams
  final Map<String, int> _pickedIngredients = {};

  /// calories per 100g * user quantity / 100
  int get _totalCalories {
    var total = 0.0;
    for (final entry in _pickedIngredients.entries) {
      final options = marketInventory[entry.key];
      if (options != null && options.isNotEmpty) {
        total += (entry.value / 100) * options.first.calories;
      }
    }
    return total.round();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _prepTimeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchResults = query.trim().isEmpty
          ? <String>[]
          : marketInventory.keys
              .where((k) => k.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  /// shows a dialog to enter quantity for the tapped ingredient
  Future<void> _showQuantityDialog(String ingredientName) async {
    final qtyCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add $ingredientName'),
        content: TextField(
          controller: qtyCtrl,
          decoration: const InputDecoration(labelText: 'Amount (grams / ml)'),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
              if (qty > 0) {
                setState(() => _pickedIngredients[ingredientName] = qty);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    qtyCtrl.dispose();
  }

  Future<void> _saveRecipe() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe name is required')),
      );
      return;
    }

    setState(() => _saving = true);

    final List<String> ingredients = _pickedIngredients.keys.toList();
    final int totalCal = _totalCalories;

    final recipe = Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      requiredIngredients: ingredients,
      prepTimeMinutes: int.tryParse(_prepTimeCtrl.text.trim()) ?? 0,
      allergens: [],
      calories: totalCal,
      macros: Macros(proteinG: 0, carbsG: 0, fatG: 0),
      nutrients: {},
    );

    await DatabaseService.instance.createRecipe(recipe);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Recipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Recipe Name *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _prepTimeCtrl,
              decoration: const InputDecoration(labelText: 'Prep Time (minutes)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text('Ingredients'),
            const SizedBox(height: 8),
            TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                labelText: 'Search Ingredients',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _onSearchChanged,
            ),
            if (_searchResults.isNotEmpty)
              SizedBox(
                height: 160,
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, i) {
                    final name = _searchResults[i];
                    return ListTile(
                      title: Text(name),
                      dense: true,
                      trailing: const Icon(Icons.add, size: 18),
                      onTap: () => _showQuantityDialog(name),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _pickedIngredients.entries.map((entry) {
                return Chip(
                  label: Text('${entry.key} (${entry.value}g)'),
                  onDeleted: () =>
                      setState(() => _pickedIngredients.remove(entry.key)),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Total Recipe Calories: $_totalCalories kcal'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveRecipe,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Recipe'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
