import 'package:flutter/material.dart';
import '../category_service.dart';
import '../models/category.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Category> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = CategoryService.instance.categories;
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
      _filteredCategories = CategoryService.instance.categories.where((
        category,
      ) {
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
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/category',
                      arguments: c.id,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Builder(
                            builder: (_) {
                              final img = c.imageUrl;
                              if (img == null || img.isEmpty) {
                                return Image.network(
                                  'https://picsum.photos/seed/${Uri.encodeComponent(c.id)}/600/600',
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, st) =>
                                      Container(color: Colors.grey.shade300),
                                );
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
