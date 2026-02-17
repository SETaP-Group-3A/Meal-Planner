import 'package:flutter/material.dart';
import '../category_service.dart';
import '../models/category.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Category> categories = CategoryService.instance.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
          children: categories.map((c) {
            return GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/category', arguments: c.id),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // image placeholder using picsum with category id as seed
                    Image.network(
                      'https://picsum.photos/seed/${Uri.encodeComponent(c.id)}/600/600',
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => Container(color: Colors.grey.shade300),
                    ),
                    Container(
                      color: Colors.black26,
                    ),
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      child: Text(
                        c.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
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
    );
  }
}