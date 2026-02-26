import 'package:flutter/material.dart';
import 'db_manager.dart';

class DatabaseTestWidget extends StatefulWidget {
  const DatabaseTestWidget({super.key});

  @override
  State<DatabaseTestWidget> createState() => _DatabaseTestWidgetState();
}

class _DatabaseTestWidgetState extends State<DatabaseTestWidget> {
  String _dbText = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadDb();
  }

  Future<void> _loadDb() async {
    await DatabaseService().seedTrialVegetables(); // Seed if needed
    final text = await DatabaseService().getAllVegetablesAsText();
    setState(() {
      _dbText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Test')),
      body: Center(child: Text(_dbText)),
    );
  }
}
