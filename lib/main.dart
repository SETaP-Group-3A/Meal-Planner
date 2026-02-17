import 'package:flutter/material.dart';
import 'views/shopping_list_screen.dart';
import 'graph_widget.dart';
import 'db_maneger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());

  // Optional: keep this for seeding + debugging. UI will also show the data.
  Future<void>(() async {
    try {
      final db = DatabaseService();
      await db.seedTrialVegetables();
      final vegs = await db.getAllVegetables();
      for (final v in vegs) {
        // ignore: avoid_print
        print('Vegetable: $v');
      }
    } catch (e, st) {
      // ignore: avoid_print
      print('DB init/query failed: $e\n$st');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'Meal Planner Home'),
        '/shopping-list': (context) => const ShoppingListScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _vegText = '';
  bool _loadingVeg = true;
  String? _vegError;

  @override
  void initState() {
    super.initState();
    _loadVegetablesForDisplay();
  }

  Future<void> _loadVegetablesForDisplay() async {
    setState(() {
      _loadingVeg = true;
      _vegError = null;
    });

    try {
      final db = DatabaseService();
      await db.seedTrialVegetables();
      final text = await db.getAllVegetablesAsText();
      if (!mounted) return;
      setState(() {
        _vegText = text;
        _loadingVeg = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _vegError = e.toString();
        _loadingVeg = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'Meal Planner',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Shopping List'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/shopping-list');
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/shopping-list');
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text("Go to Shopping List"),
            ),
            SizedBox(
              width: 300,
              height: 200,
              child: ProgressGraphWidget(userData: null),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: 320,
              height: 160,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _loadingVeg
                      ? const Center(child: CircularProgressIndicator())
                      : _vegError != null
                      ? SingleChildScrollView(
                          child: Text(
                            'Error loading vegetables:\n$_vegError',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: SelectableText(
                            _vegText,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: _loadVegetablesForDisplay,
              child: const Text('Refresh vegetables'),
            ),
          ],
        ),
      ),
    );
  }
}
