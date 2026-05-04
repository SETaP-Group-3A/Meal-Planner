import 'package:flutter/material.dart';
import '../services/location_service.dart';

/// lists mock stores ranked nearest-first using the haversine mock dorm location
class StoreLocatorScreen extends StatelessWidget {
  const StoreLocatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stores = getNearestStoresToMockUser();

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Stores')),
      body: ListView.separated(
        itemCount: stores.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final store = stores[i].key;
          final km = stores[i].value;
          final miles = km * 0.621371;
          return ListTile(
            leading: const Icon(Icons.store),
            title: Text(store.name),
            subtitle: Text(store.postcode),
            trailing: Text(
              '${miles.toStringAsFixed(1)} miles away',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          );
        },
      ),
    );
  }
}
