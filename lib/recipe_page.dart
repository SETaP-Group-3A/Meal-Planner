import 'package:flutter/material.dart';
import 'models/recipe.dart';
import 'views/app_styles.dart';
import 'services/database_service.dart';
import 'category_service.dart';
import 'mock_data.dart';

class RecipePage extends StatefulWidget {
  final Recipe recipe;

  const RecipePage({Key? key, required this.recipe}) : super(key: key);

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  bool _showAdvanced = false;
  bool _isFavourite = false;
  static const int _defaultServings = 2;
  int _currentServings = 2;

  /// indexes of ingredients the user has tapped to exclude
  final Set<int> _excludedIngredients = {};

  @override
  void initState() {
    super.initState();
    DatabaseService.instance.isFavourite(widget.recipe.id).then((fav) {
      if (mounted) setState(() => _isFavourite = fav);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// fetches existing folders then shows them as a tappable list
  Future<void> _showSaveToFolderDialog() async {
    final folders = await DatabaseService.instance.getAllFolderNames();
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save to Folder'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: folders.length,
            itemBuilder: (_, i) => ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(folders[i]),
              onTap: () async {
                final name = folders[i];
                Navigator.pop(ctx);
                await DatabaseService.instance.addRecipeToFolder(
                  widget.recipe.id,
                  name,
                );
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Saved to $name')));
                }
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

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

  /// calories scaled to current servings; falls back to marketInventory sum if recipe stores 0
  int get _scaledCalories {
    int base = widget.recipe.calories;
    if (base == 0) {
      for (final name in widget.recipe.requiredIngredients) {
        final options = marketInventory[name];
        if (options != null && options.isNotEmpty) {
          base += options.first.calories;
        }
      }
    }
    return (base * _currentServings / _defaultServings).round();
  }

  /// stepper row for adjusting serving size
  Widget _buildServingsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: _currentServings > 1
              ? () => setState(() => _currentServings--)
              : null,
        ),
        Text('Servings: $_currentServings', style: AppStyles.normalText),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => setState(() => _currentServings++),
        ),
      ],
    );
  }

  Widget _buildBasicSection() {
    final allergenText = widget.recipe.allergens.isEmpty
        ? 'None'
        : widget.recipe.allergens.join(', ');

    final scale = _currentServings / _defaultServings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildServingsRow(),
        const SizedBox(height: 8),
        Text('Ingredients', style: AppStyles.subtitleText),
        const SizedBox(height: 4),
        ...widget.recipe.requiredIngredients.asMap().entries.map((entry) {
          final i = entry.key;
          final ingredient = entry.value;
          final excluded = _excludedIngredients.contains(i);
          return GestureDetector(
            onTap: () => setState(() {
              if (excluded) {
                _excludedIngredients.remove(i);
              } else {
                _excludedIngredients.add(i);
              }
            }),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
              child: Text(
                '• $ingredient${scale != 1.0 ? ' (×${scale.toStringAsFixed(1)})' : ''}',
                style: excluded
                    ? const TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      )
                    : AppStyles.normalText,
              ),
            ),
          );
        }),
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
        Text('$_scaledCalories kcal', style: AppStyles.normalText),
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
      appBar: AppBar(
        title: Text(widget.recipe.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: 'Save to folder',
            onPressed: _showSaveToFolderDialog,
          ),
          IconButton(
            icon: Icon(
              _isFavourite ? Icons.favorite : Icons.favorite_border,
              color: _isFavourite ? Colors.red : null,
            ),
            tooltip: _isFavourite
                ? 'Remove from favourites'
                : 'Add to favourites',
            onPressed: () async {
              final next = await DatabaseService.instance.toggleFavourite(
                widget.recipe.id,
              );
              if (mounted) setState(() => _isFavourite = next);
            },
          ),
        ],
      ),
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
