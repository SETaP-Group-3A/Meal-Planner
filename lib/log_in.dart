import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.successRouteName = '/'});

  final String successRouteName;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
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

class _LoginScreenState extends State<LoginScreen> {
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

    if (email.isEmpty) {
      _emailError = 'Email is required';
      hasError = true;
    } else if (!email.contains('@')) {
      _emailError = "Email must contain '@'";
      hasError = true;
    }

    final letterCount = password.replaceAll(RegExp(r'[^A-Za-z]'), '').length;
    final numberCount = password.replaceAll(RegExp(r'[^0-9]'), '').length;

    if (password.isEmpty) {
      _passwordError = 'Password is required';
      hasError = true;
    } else if (letterCount < 7 || numberCount < 1) {
      _passwordError =
          'Password must have at least 7 letters and at least 1 number';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    final success = await _authService.login(email, password);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, widget.successRouteName);
    } else {
      setState(() {
        _loginError = 'Invalid email or password';
      });
    }
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
          ],
        ),
      ),
    );
  }
}

