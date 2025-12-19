import 'package:flutter/material.dart';
// Pastikan import file tempat MyApp didefinisikan agar bisa mengakses warna statisnya
import 'package:any_venue/main.dart'; 

class ProfileInfo extends StatelessWidget {
  final String initial;
  final String username;
  final String role;

  const ProfileInfo({
    super.key,
    required this.initial,
    required this.username,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- Avatar Container ---
        Container(
          width: 120,
          height: 120,
          decoration: ShapeDecoration(
            gradient: const LinearGradient(
              begin: Alignment(1.00, 0.50),
              end: Alignment(0.00, 0.50),
              colors: [MyApp.gumetalSlate, MyApp.darkSlate],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(360),
            ),
          ),
          child: Center(
            child: Text(
              initial,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: MyApp.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // --- Nama & Role ---
        Text(
          username,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: MyApp.gumetalSlate,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
        ),
        
        Text(
          role == "USER" ? "User" : "Owner",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: MyApp.orange.withOpacity(0.8),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
        ),
      ],
    );
  }
}