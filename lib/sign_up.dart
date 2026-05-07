import 'package:flutter/material.dart';
import 'package:meal_planner/log_in.dart';
import 'package:meal_planner/models/weekly_goals.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final AuthService _auth = AuthService();

  String? error;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    setState(() {
      error = null;
    });

    // ---------------- VALIDATION ----------------
    final emailValid =
        RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);

    final passwordValid =
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$').hasMatch(password);

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        error = "Please fill in all fields";
      });
      return;
    }

    if (!emailValid) {
      setState(() {
        error = "Enter a valid email";
      });
      return;
    }

    if (!passwordValid) {
      setState(() {
        error =
            "Password must be at least 8 characters and include at least 1 letter and 1 number";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        error = "Passwords do not match";
      });
      return;
    }

    // ---------------- REGISTER ----------------
    //Hardcode type of money
    final success = await _auth.register(email, password, GoalType.money);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        error = "Account creation failed (email already exists)";
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
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: "Confirm Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            if (error != null)
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
              ),

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

