import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/widgets/components/button.dart';

typedef AsyncVoidCallback = Future<void> Function();

class ConfirmationModal extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final AsyncVoidCallback onConfirm;
  final bool isDanger; // True = Warna Orange/Merah (untuk Delete), False = Warna Biasa
  final IconData? icon;

  const ConfirmationModal({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmText = "Yes",
    this.cancelText = "Cancel",
    this.isDanger = false,
    this.icon,
  });

  // --- STATIC METHOD UNTUK MEMANGGIL DIALOG ---
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required AsyncVoidCallback onConfirm, // <-- ganti
    String confirmText = "Confirm",
    String cancelText = "Cancel",
    bool isDanger = false,
    IconData? icon,
  }) {
    return showDialog<void>( // <-- return Future<void>
      context: context,
      builder: (context) => ConfirmationModal(
        title: title,
        message: message,
        onConfirm: onConfirm,
        confirmText: confirmText,
        cancelText: cancelText,
        isDanger: isDanger,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan warna berdasarkan tipe dialog (Danger / Normal)
    final Color themeColor = isDanger ? MyApp.orange : MyApp.gumetalSlate;
    final IconData iconData = icon ?? (isDanger ? Icons.warning_rounded : Icons.info_rounded);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Agar tinggi dialog menyesuaikan konten
          children: [
            // 1. ICON BULAT DI TENGAH
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1), // Background transparan
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                size: 32,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 20),

            // 2. JUDUL
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: MyApp.gumetalSlate,
              ),
            ),
            const SizedBox(height: 12),

            // 3. PESAN / DESKRIPSI
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // 4. TOMBOL AKSI
            Row(
              children: [
                // --- TOMBOL CANCEL ---
                Expanded(
                  child: CustomButton(
                    text: cancelText,
                    isOutlined: true,
                    isFullWidth: true, // Agar memenuhi lebar Expanded
                    color: Colors.grey,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(width: 12), // Jarak antar tombol

                // --- TOMBOL CONFIRM ---
                Expanded(
                  child: CustomButton(
                    text: confirmText,
                    isOutlined: false,
                    isFullWidth: true,
                    color: MyApp.orange,
                    onPressed: () async {
                      Navigator.pop(context); // Tutup dialog dulu
                      await onConfirm(); // Jalankan aksi
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}