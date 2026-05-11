import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/database_service.dart';

/// form screen for adding a custom recipe
class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _nameCtrl = TextEditingController();
  final _ingredientsCtrl = TextEditingController();
  final _prepTimeCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ingredientsCtrl.dispose();
    _prepTimeCtrl.dispose();
    super.dispose();
  }

  /// splits "Flour, Eggs, Milk" into ['Flour', 'Eggs', 'Milk']
  List<String> _parseList(String raw) =>
      raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

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
      requiredIngredients: _parseList(_ingredientsCtrl.text),
      prepTimeMinutes: int.tryParse(_prepTimeCtrl.text.trim()) ?? 0,
      allergens: [],
      calories: 0,
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
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Recipe Name *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ingredientsCtrl,
              decoration: const InputDecoration(
                labelText: 'Ingredients (comma-separated)',
                hintText: 'e.g. Flour, Eggs, Milk',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _prepTimeCtrl,
              decoration: const InputDecoration(labelText: 'Prep Time (minutes)'),
              keyboardType: TextInputType.number,
            ),
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
