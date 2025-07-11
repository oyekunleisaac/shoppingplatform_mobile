import 'package:flutter/material.dart';
import 'package:interview_shopping_app/screens/login_screen.dart';
import 'package:interview_shopping_app/screens/home_screen.dart';
import 'package:interview_shopping_app/screens/register_screen.dart'; // Make sure this is imported
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _defaultScreen = const LoginScreen();

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  void checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      setState(() {
        _defaultScreen = const HomeScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _defaultScreen,
      routes: {
        '/register': (context) => const RegisterScreen(), // 👈 Add this line
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
