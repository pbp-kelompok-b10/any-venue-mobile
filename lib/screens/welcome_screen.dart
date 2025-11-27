import 'package:flutter/material.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/screens/register.dart';
import 'package:any_venue/screens/login.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // PENTING: Pakai SafeArea biar tombol back & konten bawah gak ketutup sistem HP
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
            children: [
              // // 1. Tombol Back (Panah Kiri) di pojok atas
              // IconButton(
              //   onPressed: () {
              //     // Aksi kalau ditekan, misal: Navigator.pop(context);
              //   },
              //   icon: const Icon(Icons.arrow_back, color: Colors.black),
              //   padding: EdgeInsets.zero,
              //   alignment: Alignment.centerLeft,
              // ),

              const Spacer(flex: 1), // Pendorong spasi fleksibel

              // 2. Gambar Placeholder
              Center(
                child: Image.asset(
                  'assets/images/header1.jpg',
                  height: 200,
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),

              const Spacer(flex: 1), 

              // 3. Teks Judul Besar
              // Gunakan warna GunmetalSlate kamu (misal 0xFF293241)
              const Text(
                "Welcome\nto AnyVenue!",
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF293241), // Ganti dg MyApp.gunmetalSlate
                  height: 1.2, // Jarak antar baris
                ),
              ),

              const SizedBox(height: 16),

              // 4. Teks Deskripsi
              const Text(
                "Cari, sewa, dan ikuti berbagai event olahraga dengan cara baru yang lebih simple dan efisien.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey, // Atau Color(0xFF293241) dengan opacity
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 2), // Spasi agak besar di bawah sebelum tombol

              // 5. Tombol "Get Started"
              SizedBox(
                width: double.infinity, // Lebar full
                height: 56, // Tinggi tombol standar modern
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF315672), // MyApp.darkSlate
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Sudut melengkung
                    ),
                    elevation: 0, // Flat design (tanpa bayangan)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Get Started",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_circle_right_outlined, color: Colors.white),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 6. Teks "Already have an account? Sign In"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        color: Color(0xFF293241), // MyApp.gunmetalSlate
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}