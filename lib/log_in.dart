import 'package:flutter/material.dart';
import 'package:meal_planner/models/weekly_goals.dart';
import 'package:meal_planner/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.successRouteName = '/'});

  final String successRouteName;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class AuthService {
  final DatabaseService _db = DatabaseService.instance;

  Future<bool> login(String email, String password) async {
    final db = await _db.database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    return result.isNotEmpty;
  }

  Future<bool> register(String email, String password) async {
  try {
    final db = await _db.database;

    final id = DateTime.now().millisecondsSinceEpoch.toString();

    await db.insert(
      'users',
      {
        'id': id,
        'email': email,
        'password': password,
      },
    );

    await WeeklyGoals.registerNewGoals(accountId: id);

    return true;
  } catch (e) {
    print("SIGNUP ERROR: $e"); // debug log
    return false;
  }
}
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _clearSavedAccountEmail();
  }

  Future<void> _clearSavedAccountEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accountEmail');
    } catch (e) {
      // non-fatal; ignore errors while clearing prefs
    }
  }

  String? _emailError;
  String? _passwordError;
  String? _loginError;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = null;
      _passwordError = null;
      _loginError = null;
    });

    bool hasError = false;

    if (email.isEmpty) {
      _emailError = 'Email is required';
      hasError = true;
      final emailValid =
      RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);

    if (!emailValid) {
    _emailError = "Enter a valid email";
    hasError = true;
    }
  }

  final passwordValid =
  RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$').hasMatch(password);

    if (password.isEmpty) {
     _passwordError = 'Password is required';
     hasError = true;
    } else if (!passwordValid) {
      _passwordError =
        'Password must be at least 8 characters and include at least 1 letter and 1 number';
     hasError = true;
   }

    if (hasError) {
      setState(() {});
      return;
    }

    final success = await _authService.login(email, password);

    if (!mounted) return;

    if (success) {
      // fetch the user's id and load weekly goals into the provider
      // persist current account email for future app starts
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accountEmail', email);

      // ask the provider instance to load data for this account (by email)
      try {
        final weekly = Provider.of<WeeklyGoals>(context, listen: false);
        await weekly.loadFromDatabase(accountEmail: email);
      } catch (e) {
        // non-fatal — loading will be attempted again when needed
        print('Failed loading weekly goals after login: $e');
      }

      Navigator.pushReplacementNamed(context, widget.successRouteName);
    } else {
      setState(() {
        _loginError = 'Invalid email or password';
      });
    }
  }

  void _goToSignUp() {
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: _emailError,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText: _passwordError,
                ),
                obscureText: true,
              ),
            ),

            const SizedBox(height: 16),

            if (_loginError != null)
              Text(
                _loginError!,
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _handleLogin,
              child: const Text('Login'),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: _goToSignUp,
              child: const Text("Create account"),
            ),
          ],
        ),
      ),
    );
  }
}