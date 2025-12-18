import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:any_venue/main.dart';

class ConfirmationModal extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
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
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = "Confirm",
    String cancelText = "Cancel",
    bool isDanger = false,
    IconData? icon,
  }) {
    showDialog(
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

            // 4. TOMBOL AKSI (Row)
            Row(
              children: [
                // Tombol Cancel
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: Colors.grey[700],
                    ),
                    child: Text(
                      cancelText,
                      style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Tombol Confirm
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Tutup dialog dulu
                      onConfirm(); // Jalankan aksi
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold),
                    ),
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