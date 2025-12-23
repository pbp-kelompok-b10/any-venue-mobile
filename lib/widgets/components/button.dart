import 'package:flutter/material.dart';
import 'package:any_venue/main.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final List<Color>? gradientColors; 
  final double? width;
  final bool isFullWidth;
  final IconData? icon;
  final bool isOutlined;
  final bool isLoading;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.gradientColors, 
    this.width,
    this.isFullWidth = false,
    this.icon,
    this.isOutlined = false,
    this.isLoading = false, // Default false
    this.borderRadius = 14.0, 
  });

  @override
  Widget build(BuildContext context) {
    // 1. Tentukan Warna Dasar
    final Color themeColor = color ?? MyApp.darkSlate;
    
    // 2. Cek apakah menggunakan Gradasi?
    // Gradasi hanya aktif jika gradientColors diisi DAN tidak sedang mode outline
    final bool useGradient = gradientColors != null && gradientColors!.isNotEmpty && !isOutlined;

    // 3. Logika Warna & Border
    final Color backgroundColor = isOutlined ? Colors.white : themeColor;
    final Color foregroundColor = isOutlined ? themeColor : Colors.white;
    final Border? border = isOutlined
        ? Border.all(color: themeColor, width: 1.5)
        : null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      elevation: isOutlined ? 0 : 4, // Efek bayangan (elevation) manual
      shadowColor: useGradient ? themeColor.withOpacity(0.4) : Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: (isLoading || onPressed == null) ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          width: isFullWidth ? double.infinity : width,
          height: 52, 
          decoration: BoxDecoration(
            // Jika useGradient true, pakai LinearGradient. Jika tidak, pakai solid color.
            gradient: useGradient
                ? LinearGradient(
                    begin: const Alignment(0.5, 0), // Top Center
                    end: const Alignment(0.5, 1), // Bottom Center
                    colors: gradientColors!,
                  )
                : null,
            color: useGradient ? null : backgroundColor, 
            borderRadius: BorderRadius.circular(borderRadius),
            border: border,
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: foregroundColor,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: foregroundColor,
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(icon, size: 20, color: foregroundColor),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}