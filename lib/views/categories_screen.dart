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
  List<Category> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    final src = widget.categories ?? CategoryService.instance.categories;
    _filteredCategories = src.where((c) => c.id.startsWith('c-')).toList();
    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      final src = widget.categories ?? CategoryService.instance.categories;
      _filteredCategories = src.where((category) {
        if (!category.id.startsWith('c-')) return false;
        return category.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
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
                                return Image.network(
                                  'https://picsum.photos/seed/${Uri.encodeComponent(c.id)}/600/600',
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, st) =>
                                      Container(color: Colors.grey.shade300),
                                );
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
