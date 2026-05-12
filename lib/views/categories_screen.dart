import 'package:flutter/material.dart';
import '../category_service.dart';
import '../models/category.dart';

class CategoriesScreen extends StatefulWidget {
  final List<Category>? categories;
  const CategoriesScreen({super.key, this.categories});

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();
  List<Category> _filteredCategories = [];
  List<Category> _allCategories = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCategories);
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  List<Category> _applySearch(List<Category> src) {
    final query = _searchController.text.toLowerCase();
    return src
        .where((c) => c.id.startsWith('c-') && c.name.toLowerCase().contains(query))
        .toList();
  }

  /// queries the database and refreshes the grid
  Future<void> _loadCategories() async {
    final src = widget.categories ?? await CategoryService.instance.getAllCategories();
    if (!mounted) return;
    setState(() {
      _allCategories = src;
      _filteredCategories = _applySearch(src);
    });
  }

  void _filterCategories() {
    setState(() => _filteredCategories = _applySearch(_allCategories));
  }

  Future<void> _showDeleteDialog(Category category) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text('Delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await CategoryService.instance.removeCategory(category.id);
              _loadCategories();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// shows a dialog to create a new category
  Future<void> _showCreateCategoryDialog() async {
    _newCategoryController.clear();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: _newCategoryController,
          decoration: const InputDecoration(labelText: 'Category Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = _newCategoryController.text.trim();
              if (name.isNotEmpty) {
                await CategoryService.instance.addCategory(
                  name: name,
                  targetRoute: '/category',
                );
                _loadCategories();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCategoryDialog,
        tooltip: 'New category',
        child: const Icon(Icons.create_new_folder),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
                children: _filteredCategories.map((c) {
                  return GestureDetector(
                    onLongPress: () => _showDeleteDialog(c),
                    onTap: () {
                      final route = c.targetRoute;
                      if (route != null &&
                          route.trim().isNotEmpty &&
                          route.trim().startsWith('/')) {
                        Navigator.pushNamed(
                          context,
                          route.trim(),
                          arguments: c.id,
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Builder(
                            builder: (_) {
                              final img = c.imageUrl;
                              if (img == null) {
                                return Container(color: Colors.grey.shade300);
                              }
                              if (img.trim().isEmpty) {
                                return Container(); // explicit empty -> no image / no placeholder
                              }
                              if (img.startsWith('asset:')) {
                                final assetPath = img.replaceFirst(
                                  'asset:',
                                  '',
                                );
                                return Image.asset(
                                  assetPath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, st) =>
                                      Container(color: Colors.grey.shade300),
                                );
                              }
                              return Image.network(
                                img,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, st) =>
                                    Container(color: Colors.grey.shade300),
                              );
                            },
                          ),

                          Container(color: Colors.black26),

                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                c.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 6,
                                      color: Colors.black54,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
