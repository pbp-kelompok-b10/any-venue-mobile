import 'dart:async';
import 'package:flutter/material.dart';
import 'package:any_venue/main.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Panggil fungsi timer saat halaman dibuat
    startSplashTimer();
  }

  // Fungsi untuk menunggu 3 detik lalu pindah
  void startSplashTimer() {
    var duration = const Duration(seconds: 3);
    Timer(duration, () {
      // Pindah ke WelcomeScreen & hapus Splash dari riwayat navigasi
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan Logo
    return Scaffold(
      backgroundColor: MyApp.darkSlate,
      body: Center(
        child: Image.asset('assets/images/logo_light.png', width: 120),
      ),
    );
  }
}
