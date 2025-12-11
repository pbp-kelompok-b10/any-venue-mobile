import 'package:flutter/material.dart';
import 'package:any_venue/main.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  // Ini warna "TEMA" tombol.
  // - Kalau Solid: Jadi warna Background.
  // - Kalau Outline: Jadi warna Teks & Garis Pinggir.
  final Color? color;

  final double? width;
  final bool isFullWidth;
  final IconData? icon;
  final bool
  isOutlined; // TRUE = Mode Garis Tepi (Bg Putih), FALSE = Mode Blok Warna

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color, // Opsional, kalau kosong nanti pakai default biru tua
    this.width,
    this.isFullWidth = false,
    this.icon,
    this.isOutlined = false, // Default-nya Solid
  });

  @override
  Widget build(BuildContext context) {
    // 1. Tentukan Warna Tema (Default ke Biru Tua kalau user gak isi color)
    final Color themeColor = color ?? MyApp.darkSlate;
    // 2. Logika Tukar Warna
    // - Jika Outlined: Background Putih, Teks themeColor
    // - Jika Solid: Background themeColor, Teks Putih
    final Color backgroundColor = isOutlined ? Colors.white : themeColor;
    final Color foregroundColor = isOutlined ? themeColor : Colors.white;

    // 3. Logika Border
    // - Jika Outlined: Border muncul dengan warna themeColor
    // - Jika Solid: Tidak ada border (BorderSide.none)
    final BorderSide borderSide = isOutlined
        ? BorderSide(color: themeColor, width: 1.5)
        : BorderSide.none;

    return SizedBox(
      // Logika Lebar: Full / Manual / Otomatis
      width: isFullWidth ? double.infinity : width,
      height: 52, // Tinggi standar tombol
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor:
              foregroundColor, // Mengatur warna Teks & Icon & Ripple Effect
          elevation: isOutlined
              ? 0
              : 2, // Outline biasanya flat (0), Solid ada bayangan dikit (2)
          side: borderSide, // Pasang border disini
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Lengkungan sudut
          ),
          // Padding diatur agar teks tidak terlalu mepet kalau tombolnya kecil
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Jika ada icon, tampilkan di kiri teks
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600, // Semi bold
                color: foregroundColor, // Warna teks mengikuti logika di atas
              ),
            ),

            const SizedBox(width: 5), 

            if (icon != null) ...[
              Icon(icon, size: 20, color: foregroundColor),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}
