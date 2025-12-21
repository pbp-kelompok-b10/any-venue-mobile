import 'package:flutter/material.dart';
import 'package:any_venue/main.dart'; 
import 'package:any_venue/widgets/components/avatar.dart';

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
        UserAvatar(
          initial: initial,
          size: 120,
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