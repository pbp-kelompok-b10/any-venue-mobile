import 'package:flutter/material.dart';
import 'package:any_venue/main.dart'; 

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged; // Fungsi ketika user mengetik
  final VoidCallback? onTap; // Fungsi jika bar ditekan (opsional)
  final TextEditingController? controller; // Controller untuk mengatur teks (opsional)
  final bool readOnly; // True = Jadi tombol (keyboard gak muncul), False = Jadi input biasa
  final bool autoFocus; // True = Keyboard langsung muncul pas halaman dibuka

  const CustomSearchBar({
    super.key,
    this.hintText = "Search...", // Default text
    this.onChanged,
    this.onTap,
    this.controller,
    this.readOnly = false,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Dekorasi Container Luar (Shadow & Radius)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Lengkungan sudut
        border: Border.all(
          color: Colors.grey.shade300, // Warna border tipis
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02), // Bayangan sangat tipis
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        autofocus: autoFocus,
        onChanged: onChanged,
        onTap: onTap,
        
        style: const TextStyle(
          fontSize: 14,
          color: MyApp.gumetalSlate, 
        ),
        
        // Dekorasi Input (Icon & Hint)
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade400, 
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: MyApp.gumetalSlate,
            size: 24,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}