import 'package:flutter/material.dart';
import 'models/recipe.dart';
import 'views/app_styles.dart';

class RecipePage extends StatefulWidget {
  final Recipe recipe;

  const RecipePage({Key? key, required this.recipe}) : super(key: key);

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  bool _showAdvanced = false;

  Widget _buildToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Basic', style: AppStyles.normalText),
        Switch(
          value: _showAdvanced,
          onChanged: (value) => setState(() => _showAdvanced = value),
        ),
        Text('Advanced', style: AppStyles.normalText),
      ],
    );
  }

  Widget _buildBasicSection() {
    final allergenText = widget.recipe.allergens.isEmpty
        ? 'None'
        : widget.recipe.allergens.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ingredients', style: AppStyles.subtitleText),
        const SizedBox(height: 4),
        ...widget.recipe.requiredIngredients.map(
          (ingredient) => Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
            child: Text('• $ingredient', style: AppStyles.normalText),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Prep Time: ${widget.recipe.prepTimeMinutes} min',
          style: AppStyles.normalText,
        ),
        const SizedBox(height: 12),
        Text(
          'Allergens: $allergenText',
          style: widget.recipe.allergens.isEmpty
              ? AppStyles.normalText
              : AppStyles.highlightBad,
        ),
      ],
    );
  }

  Widget _buildAdvancedSection() {
    final macros = widget.recipe.macros;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Text('Calories', style: AppStyles.subtitleText),
        const SizedBox(height: 4),
        Text('${widget.recipe.calories} kcal', style: AppStyles.normalText),
        const SizedBox(height: 12),
        Text('Macros', style: AppStyles.subtitleText),
        const SizedBox(height: 4),
        Text(
          'Protein: ${macros.proteinG}g  |  '
          'Carbs: ${macros.carbsG}g  |  '
          'Fat: ${macros.fatG}g',
          style: AppStyles.normalText,
        ),
        const SizedBox(height: 12),
        Text('Nutrients', style: AppStyles.subtitleText),
        const SizedBox(height: 4),
        ...widget.recipe.nutrients.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
            child: Text(
              '${entry.key}: ${entry.value}',
              style: AppStyles.normalText,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.recipe.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildToggle(),
            const Divider(height: 24),
            _buildBasicSection(),
            if (_showAdvanced) _buildAdvancedSection(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Add to shopping list logic later
              },
              child: const Text('Add to Shopping List'),
            ),
          ],
        ),
      ),
    );
  }
}
