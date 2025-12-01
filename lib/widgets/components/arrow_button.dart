import 'package:flutter/material.dart';

class ArrowButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;

  const ArrowButton({
    super.key, 
    this.onTap,
    this.size = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Icon(
        Icons.chevron_right,
        size: size * 0.6,
        color: const Color(0xFF293241), // Gunmetal Slate
      ),
    );

    // Kalau ada onTap, bungkus dengan GestureDetector/InkWell
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: buttonContent,
      );
    }

    // Kalau tidak ada aksi klik (cuma hiasan), return langsung
    return buttonContent;
  }
}