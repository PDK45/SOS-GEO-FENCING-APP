import 'package:flutter/material.dart';
import 'login_screen.dart'; 

void main() {
  runApp(const SafetyApp());
}

class SafetyApp extends StatelessWidget {
  const SafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeSoul',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // iPad/iOS Grouped Background Color
        scaffoldBackgroundColor: const Color(0xFFF2F2F7), 
        
        // System Blue
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF007AFF), 
        
        // Cards are Pure White
        cardColor: const Color(0xFFFFFFFF),
        
        // Modern Typography
        fontFamily: 'Roboto', // Or 'San Francisco' if available via pubspec
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF2F2F7),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
          iconTheme: IconThemeData(color: Color(0xFF007AFF)),
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF), // System Blue
            foregroundColor: Colors.white,
            elevation: 0, // Flat styling
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, // iOS style: no border, just background
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      home: const LoginScreen(), 
    );
  }
}