import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ------------------- MyApp -------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// ------------------- HomePage -------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// ------------------- AuthService -------------------
class AuthService {
  // Mock login: only accepts test@test.com / password123
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate network
    if (email == "test@test.com" && password == "password123") {
      return true;
    }
    return false;
  }
}

// ------------------- _HomePageState -------------------
class _HomePageState extends State<HomePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _loginError; // Shows login failure

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ------------------- Login Handler -------------------
  void _handleLogin() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text;

  setState(() {
    _emailError = null;
    _passwordError = null;
    _loginError = null;
  });

  bool hasError = false;

  // ------------------- Email Validation -------------------
  if (email.isEmpty) {
    _emailError = "Email is required";
    hasError = true;
  } else if (!email.contains("@")) {
    _emailError = "Email must contain '@'";
    hasError = true;
  }

  // ------------------- Password Validation -------------------
  final letterCount = password.replaceAll(RegExp(r'[^A-Za-z]'), '').length;
  final numberCount = password.replaceAll(RegExp(r'[^0-9]'), '').length;

  if (password.isEmpty) {
    _passwordError = "Password is required";
    hasError = true;
  } else if (letterCount < 7 || numberCount < 1) { // numberCount >=1 now
    _passwordError =
        "Password must have at least 7 letters and at least 1 number";
    hasError = true;
  }

  if (hasError) {
    setState(() {}); // Update UI with errors
    return;
  }

  // ------------------- Call AuthService -------------------
  bool success = await _authService.login(email, password);

  if (success) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoggedInHome()),
    );
  } else {
    setState(() {
      _loginError = "Invalid email or password";
    });
  }
}

  // ------------------- Build UI -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
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
          ],
        ),
      ),
    );
  }
}

// ------------------- Placeholder Home After Login -------------------
class LoggedInHome extends StatelessWidget {
  const LoggedInHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logged In Home'),
      ),
      body: const Center(
        child: Text(
          'Welcome! You are logged in.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
      
      
//create accounts when database is linked

