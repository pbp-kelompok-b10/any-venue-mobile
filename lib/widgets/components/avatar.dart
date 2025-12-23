import 'package:flutter/material.dart';
import 'package:any_venue/main.dart';
import 'package:google_fonts/google_fonts.dart';

class UserAvatar extends StatelessWidget {
  final String initial;
  final double size;
  final double? fontSize;

  const UserAvatar({
    super.key,
    required this.initial,
    this.size = 100.0, // Default ukuran 100 jika tidak diisi
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(1.00, 0.50),
          end: Alignment(0.00, 0.50),
          colors: [
            MyApp.gumetalSlate,
            MyApp.darkSlate,
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size), 
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.nunitoSans(
            fontSize: fontSize ?? (size * 0.4), 
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}