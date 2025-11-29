import 'package:flutter/material.dart';
import 'package:any_venue/main.dart';

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double cardWidth = (MediaQuery.of(context).size.width - 48 - 24) / 3;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: MyApp.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: MyApp.orange, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: MyApp.gumetalSlate, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}