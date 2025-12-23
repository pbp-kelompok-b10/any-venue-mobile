import 'package:any_venue/main.dart';
import 'package:flutter/material.dart';

class ArrowButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;
  final bool isLeft;

  const ArrowButton({
    super.key, 
    this.onTap,
    this.size = 32.0,
    this.isLeft = false, // Default false (Arah Kanan)
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
        // Logic ganti icon berdasarkan isLeft
        isLeft ? Icons.chevron_left : Icons.chevron_right,
        size: size * 0.6,
        color: MyApp.gumetalSlate,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: buttonContent,
      );
    }

    return buttonContent;
  }
}