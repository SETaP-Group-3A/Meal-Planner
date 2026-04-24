import 'package:flutter/material.dart';
import 'package:meal_planner/log_in.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService _auth = AuthService();

  String? error;

  bool _validateEmail(String email) {
    return email.contains('@');
  }

  bool _validatePassword(String password) {
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasMinLength = password.length >= 7;
    return hasNumber && hasMinLength;
  }

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    setState(() {
      error = null;
    });

    // ---------------- VALIDATION ----------------
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        error = "Please fill in all fields";
      });
      return;
    }

    if (!_validateEmail(email)) {
      setState(() {
        error = "Email must contain '@'";
      });
      return;
    }

    if (!_validatePassword(password)) {
      setState(() {
        error =
            "Password must be at least 7 characters and include at least 1 number";
      });
      return;
    }

    // ---------------- REGISTER ----------------
    final success = await _auth.register(email, password);

    if (success) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        error = "Account creation failed (email may already exist)";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: register,
              child: const Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}