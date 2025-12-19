import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:any_venue/main.dart'; 

class CustomToast {
  static void show(
    BuildContext context, {
    required String message,
    String? subMessage,
    bool isError = false,
  }) {
    // 1. Dapatkan Overlay State
    final overlayState = Overlay.of(context);
    
    // 2. Buat Entry Overlay
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        // Gunakan TweenAnimationBuilder untuk efek slide down yang halus
        return Positioned(
          top: MediaQuery.of(context).padding.top + 10, // Muncul di bawah status bar + 10px
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: -100, end: 0), // Animasi dari atas layar (-100) ke posisi 0
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack, // Efek membal sedikit biar keren
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isError ? MyApp.orange : MyApp.darkSlate,
                  borderRadius: BorderRadius.circular(16), // Lebih bulat biar modern
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      isError ? Icons.cancel_outlined : Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message,
                            style: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          if (subMessage != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subMessage,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Tombol Close kecil (opsional)
                    GestureDetector(
                      onTap: () {
                        overlayEntry.remove();
                      },
                      child: const Icon(Icons.close, color: Colors.white70, size: 18),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // 3. Masukkan ke Layar
    overlayState.insert(overlayEntry);

    // 4. Hapus otomatis setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}