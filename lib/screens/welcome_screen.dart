import 'package:flutter/material.dart';
import 'package:any_venue/main.dart'; 
import 'package:any_venue/screens/register.dart';
import 'package:any_venue/screens/login.dart';
import 'package:any_venue/widgets/button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar agar responsif
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ------------------------------------------------
          // LAYER 1: GAMBAR BACKGROUND (Setengah Atas)
          // ------------------------------------------------
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.6,
            child: Image.asset(
              'assets/images/header.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // ------------------------------------------------
          // LAYER 2: GRADASI PUTIH (FADING EFFECT)
          // ------------------------------------------------
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.61,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.01, 1.0],
                  colors: [
                    Colors.transparent, 
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),

          // ------------------------------------------------
          // LAYER 3: KONTEN TEKS & TOMBOL (Bagian Bawah)
          // ------------------------------------------------
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome\nto AnyVenue!",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: MyApp.gumetalSlate,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Deskripsi
                  const Text(
                    "Cari, sewa, dan ikuti berbagai event olahraga dengan cara baru yang lebih simpel dan efisien.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40), 

                  // Tombol Get Started
                  Button(
                    text: "Get Started",
                    isFullWidth: true,
                    color: MyApp.darkSlate,
                    icon: Icons.arrow_circle_right_outlined,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Link Sign In
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: MyApp.gumetalSlate.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterPage()),
                              );
                            },
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                color: MyApp.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}