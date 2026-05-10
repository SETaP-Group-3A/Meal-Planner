import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bcrypt/bcrypt.dart';
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

  // ---------------- LOGIN ----------------

  Future<bool> login(String email, String password) async {
    final db = await _db.database;

    // Find user by email only
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    // User not found
    if (result.isEmpty) {
      return false;
    }

    // Get stored hashed password
    final storedHash = result.first['password'] as String;

    // Compare entered password with stored hash
    final passwordMatches = BCrypt.checkpw(
      password,
      storedHash,
    );

    return passwordMatches;
  }

  // ---------------- REGISTER ----------------

  Future<bool> register(
    String email,
    String password,
    GoalType type,
  ) async {
    try {
      final db = await _db.database;

      final id = DateTime.now()
          .millisecondsSinceEpoch
          .toString();

      await db.insert(
        'users',
        {
          'id': id,
          'email': email,
          'password': password,
        },
      );

      final prefs = await SharedPreferences.getInstance();

      prefs.setString(
        'goal',
        type.toString(),
      );

      await WeeklyGoals.registerNewGoals(
        accountId: id,
        goalType: type,
      );

      return true;
    } catch (e) {
      print("SIGNUP ERROR: $e"); // For debugging purposes
      return false;
    }
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _loginError;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    if (kDebugMode) return;

     _clearSavedAccountEmail();
  }

  Future<void> _clearSavedAccountEmail() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.remove('accountEmail');
    } catch (e) {
      // ignore
    }
  }

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

    // ---------------- EMAIL VALIDATION ----------------

    final emailValid =
        RegExp(r'^[^@]+@[^@]+\.[^@]+')
            .hasMatch(email);

    if (email.isEmpty) {
      _emailError = 'Email is required';
      hasError = true;
    } else if (!emailValid) {
      _emailError = 'Enter a valid email';
      hasError = true;
    }

    // ---------------- PASSWORD VALIDATION ----------------

    final passwordValid =
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$')
            .hasMatch(password);

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

    // ---------------- LOGIN ----------------

    final success =
        await _authService.login(email, password);

    if (!mounted) return;

    if (success) {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        'accountEmail',
        email,
      );

      final goal = prefs.getString('goal');

      try {
        if (!mounted) return;

        final weekly = Provider.of<WeeklyGoals>(
          context,
          listen: false,
        );

        await weekly.loadFromDatabase(
          accountEmail: email,
          expectedType: GoalTypes.fromDbString(
            goal ?? "money",
          ),
        );
      } catch (e) {
        if (kDebugMode) {
          print(
            'Failed loading weekly goals after login: $e',
          );
        }
      }

      Navigator.pushReplacementNamed(
        context,
        widget.successRouteName,
      );
    } else {
      setState(() {
        _loginError =
            'Invalid email or password';
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
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24.0,
              ),
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
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24.0,
              ),
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
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _handleLogin,
              child: const Text('Login'),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: _goToSignUp,
              child:
                  const Text("Create account"),
            ),
          ],
        ),
      ),
    );
  }
}