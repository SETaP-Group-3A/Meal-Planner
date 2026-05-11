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
  bool _saving = false;
  String _selectedIngredient = marketInventory.keys.first;
  final List<String> _pickedIngredients = [];

  /// sums calories from the first market option for each picked ingredient
  int get _totalCalories {
    var total = 0;
    for (final name in _pickedIngredients) {
      final options = marketInventory[name];
      if (options != null && options.isNotEmpty) {
        total += options.first.calories;
      }
    }
    return total;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _prepTimeCtrl.dispose();
    super.dispose();
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

    final recipe = Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      requiredIngredients: List.from(_pickedIngredients),
      prepTimeMinutes: int.tryParse(_prepTimeCtrl.text.trim()) ?? 0,
      allergens: [],
      calories: _totalCalories,
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
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedIngredient,
                    items: marketInventory.keys.map((name) {
                      return DropdownMenuItem(value: name, child: Text(name));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedIngredient = val!),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (!_pickedIngredients.contains(_selectedIngredient)) {
                      setState(() => _pickedIngredients.add(_selectedIngredient));
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _pickedIngredients.map((ing) {
                return Chip(
                  label: Text(ing),
                  onDeleted: () => setState(() => _pickedIngredients.remove(ing)),
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
