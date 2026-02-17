import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseService {
  static Database? _database;
  static bool _factoryInitDone = false;

  static void _ensureDatabaseFactoryInitialized() {
    if (_factoryInitDone) return;

    // If nobody assigned it yet, use sqflite's default factory (mobile).
    // Note: On desktop/web this still won't make sqflite work; it prevents
    // "databaseFactory not initialized" when the default is available.

    _factoryInitDone = true;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    _ensureDatabaseFactoryInitialized();

    final String path = join(await getDatabasesPath(), 'meal_planner.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE vegetables(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            unit TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Insert some trial rows if the table is empty.
  Future<void> seedTrialVegetables() async {
    final db = await database;

    final countRes = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM vegetables',
    );
    final count = Sqflite.firstIntValue(countRes) ?? 0;
    if (count > 0) return;

    await db.insert('vegetables', {
      'name': 'Carrot',
      'quantity': 5,
      'unit': 'pcs',
    });

    await db.insert('vegetables', {
      'name': 'Potato',
      'quantity': 2,
      'unit': 'kg',
    });

    await db.insert('vegetables', {
      'name': 'Onion',
      'quantity': 3,
      'unit': 'pcs',
    });
  }

  Future<List<Map<String, Object?>>> getAllVegetables() async {
    final db = await database;
    return db.query('vegetables', orderBy: 'id ASC');
  }

  Future<String> getAllVegetablesAsText() async {
    final vegs = await getAllVegetables();
    if (vegs.isEmpty) return 'No vegetables found.';

    final b = StringBuffer();
    for (final v in vegs) {
      b.writeln('#${v['id']}: ${v['name']} — ${v['quantity']} ${v['unit']}');
    }
    return b.toString().trimRight();
  }
}
