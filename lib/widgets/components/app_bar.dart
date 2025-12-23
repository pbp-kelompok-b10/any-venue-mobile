import 'package:flutter/material.dart';
import 'package:any_venue/main.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true, // Default true, set false untuk hilangkan back button
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: !showBackButton, // Kalau ga ada back button, center title true
      
      automaticallyImplyLeading: false,

      title: Text(
        title,
        style: GoogleFonts.nunitoSans(
          color: MyApp.gumetalSlate,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
      
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,

      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: MyApp.gumetalSlate.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
      ),

      // 3. LOGIC TOMBOL BACK
      leading: showBackButton
          ? IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_left_rounded,
                size: 32,
                color: MyApp.gumetalSlate,
              ),
              onPressed: () => Navigator.pop(context, true),
            )
          : null, // Jika false, leading menjadi null (kosong)
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}