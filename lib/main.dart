import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import the Login Screen

void main() {
  runApp(const SafetyApp());
}

class SafetyApp extends StatelessWidget {
  const SafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PS03 Safety App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // The app starts at the Login screen to enforce profile setup
      home: const LoginScreen(), 
    );
  }
}