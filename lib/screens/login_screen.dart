import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_animate/flutter_animate.dart';

import '../services/api_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  String _email = '';
  String _password = '';
  String _error = '';
  bool _loading = false;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void handleLogin() async {
    if (_email.isEmpty || _password.isEmpty) {
      setState(() => _error = "Please fill all fields.");
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final response = await ApiService.login(_email, _password);
      setState(() => _loading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setInt('user_id', data['user']['id']);

        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      } else {
        final msg = jsonDecode(response.body)['message'] ?? 'Login failed';
        setState(() => _error = msg);
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'An error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Scaffold(
        appBar: AppBar(title: const Text("Login")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (val) => _email = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (val) => _password = val,
              ),
              const SizedBox(height: 12),
              if (_error.isNotEmpty)
                Text(
                  _error,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 12),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: handleLogin,
                child: const Text("Login"),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text("Don't have an account? Register"),
              )
            ],
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
        ),
      ),
    );
  }
}
