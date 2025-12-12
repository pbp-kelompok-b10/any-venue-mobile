import 'package:flutter/material.dart';
import 'package:any_venue/main.dart'; 

class Header extends StatelessWidget {
  final String title;
  // Opsional: tambahkan properti jika ingin ada tombol back
//   final bool showBackButton; 
//   final VoidCallback? onBackPressed;

  const Header({
    super.key,
    required this.title,
    //this.showBackButton = false, // Default false (tidak ada tombol back)
    //this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 1. KUNCI UTAMA: Set tinggi fix 56.0 (standar AppBar)
      height: kToolbarHeight, 
      width: double.infinity,
      
      // 2. Padding hanya Horizontal (Kiri-Kanan), vertikal diatur otomatis oleh alignment
      padding: const EdgeInsets.symmetric(horizontal: 16),
      
      // 3. Alignment agar konten berada di tengah secara vertikal (seperti AppBar)
      alignment: Alignment.centerLeft, 

      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          // Shadow custom kamu (tetap dipertahankan)
          BoxShadow(
            color: const Color(0x0C683BFC), 
            blurRadius: 12,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          )
        ],
      ),
      
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Jika ingin fitur back button seperti AppBar contoh:
        //   if (showBackButton) 
        //     Padding(
        //       padding: const EdgeInsets.only(right: 16.0), // Jarak antara icon dan text
        //       child: IconButton(
        //         padding: EdgeInsets.zero, // Hilangkan padding bawaan icon agar rapi
        //         constraints: const BoxConstraints(), // Hilangkan constraint minimum
        //         icon: const Icon(
        //           Icons.keyboard_arrow_left_rounded,
        //           size: 32,
        //           color: MyApp.gumetalSlate,
        //         ),
        //         onPressed: onBackPressed ?? () => Navigator.pop(context),
        //       ),
        //     ),

          // Judul
          Text(
            title,
            style: const TextStyle( // Style disamakan persis dengan contoh target
              color: MyApp.gumetalSlate,
              fontWeight: FontWeight.bold,
              fontSize: 18, 
              // height: 1.50, // Dihapus atau di-set normal agar center vertikalnya pas
            ),
          ),
        ],
      ),
    );
  }
}