import 'package:flutter/material.dart';

// ------------------- LoginScreen -------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.successRouteName = '/'});

  final String successRouteName;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// ------------------- AuthService -------------------
class AuthService {
  // Mock login: only accepts test@test.com / password123
  final Map<String, String> _accounts = {
    "test@test.com": "password123",
  };

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate network
    return _accounts[email] == password;
  }

  Future<String?> createAccount(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate network

    if (_accounts.containsKey(email)) {
      return 'Account already exists';
    }

    _accounts[email] = password;
    return null; // null means success
  }
}

// ------------------- _LoginScreenState -------------------
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _createEmailController = TextEditingController();
  final TextEditingController _createPasswordController =
      TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _loginError;
  String? _createError;

  final AuthService _authService = AuthService();
  bool _showCreateAccount = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _createEmailController.dispose();
    _createPasswordController.dispose();
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

  // ------------------- Create Account Handler -------------------
  void _handleCreateAccount() async {
    final email = _createEmailController.text.trim();
    final password = _createPasswordController.text;

    setState(() {
      _createError = null;
    });

    bool hasError = false;

    if (email.isEmpty || !email.contains('@')) {
      _createError = "Enter a valid email";
      hasError = true;
    }

    final letterCount = password.replaceAll(RegExp(r'[^A-Za-z]'), '').length;
    final numberCount = password.replaceAll(RegExp(r'[^0-9]'), '').length;

    if (password.isEmpty || letterCount < 7 || numberCount < 1) {
      _createError =
          "Password must have at least 7 letters and at least 1 number";
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    final error = await _authService.createAccount(email, password);

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _createError = error;
      });
    } else {
      // Account created successfully, navigate to login
      setState(() {
        _showCreateAccount = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Please log in.')),
      );
    }
  }

  // ------------------- Build UI -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showCreateAccount ? 'Create Account' : 'Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_showCreateAccount) ...[
                // -------- Login Form --------
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: _emailError,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: _passwordError,
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                if (_loginError != null && _loginError!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _loginError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _handleLogin,
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showCreateAccount = true;
                    });
                  },
                  child: const Text('Create Account'),
                ),
              ] else ...[
                // -------- Create Account Form --------
                TextField(
                  controller: _createEmailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _createPasswordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                if (_createError != null && _createError!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _createError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _handleCreateAccount,
                  child: const Text('Create Account'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showCreateAccount = false;
                    });
                  },
                  child: const Text('Back to Login'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}