import 'dart:async';
import 'package:any_venue/main.dart';
import 'package:flutter/material.dart';
import 'package:any_venue/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startSplashTimer();
  }

  void startSplashTimer() {
    var duration = const Duration(seconds: 3);
    Timer(duration, () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.50, -0.00), // Top Center
            end: Alignment(0.50, 1.00),    // Bottom Center
            colors: [
              MyApp.darkSlate, // Warna Atas
              MyApp.gumetalSlate, // Warna Bawah
            ],
          ),
        ),
        child: Center(
          // Logo tetap di tengah
          child: Image.asset('assets/images/logo_light.png', width: 120),
        ),
      ),
    );
  }
}