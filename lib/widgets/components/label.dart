import 'package:flutter/material.dart';

class InfoLabel extends StatelessWidget {
  final String label;
  final IconData? icon; // Icon opsional
  final Color color;
  final Color contentColor;
  
  // Parameter styling tambahan (Opsional)
  final EdgeInsetsGeometry? padding;
  final double fontSize;
  final double iconSize;

  const InfoLabel({
    super.key,
    required this.label,
    this.icon,
    required this.color,
    this.contentColor = Colors.white,
    this.padding, // Bisa custom padding
    this.fontSize = 14, // Default ukuran font
    this.iconSize = 20, // Default ukuran icon
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Kalau padding tidak diisi, pakai default (16, 10). Kalau diisi, pakai yg diisi.
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: contentColor, size: iconSize),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: contentColor,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}