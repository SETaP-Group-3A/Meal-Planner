import 'package:flutter/material.dart';
import 'package:meal_planner/views/app_styles.dart';
import 'package:meal_planner/views/categories_screen.dart';
import 'package:meal_planner/views/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/shopping_list_screen.dart';
import 'graph_widget.dart';
import 'views/category_detail_screen.dart';
import 'views/category_content_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: TextTheme(
          bodyMedium: AppStyles.normalText,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(),
        useMaterial3: true,
        textTheme: TextTheme(
          bodyMedium: AppStyles.normalText,
        ),
      ),
      //Also check settings
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'Meal Planner Home'),
        '/shopping-list': (context) => const ShoppingListScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/category': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          return CategoryContentScreen(
            categoryId: args is String ? args : null,
          );
        },
        '/settings': (context) => const SettingsScreen(),
        '/settings/account': (context) => AccountSettingsScreen(),
        '/settings/accessibility': (context) => const AccessibilitySettingsScreen(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
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
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Shopping List'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/shopping-list');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/categories');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            )
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 24),
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
          ],
        ),
      ),
    );
  }
}
