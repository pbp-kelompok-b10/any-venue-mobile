import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:any_venue/main.dart'; 
import 'package:any_venue/booking/models/booking_slot.dart';

class SlotsSection extends StatelessWidget {
  const SlotsSection({
    super.key,
    required this.futureSlots,
    required this.selectedSlotIds,
    required this.onToggle,
    required this.isSlotPast,
    this.onCancelBookedSlot,
    this.cancellingSlotIds,
  });

  final Future<List<BookingSlot>> futureSlots;
  final Set<int> selectedSlotIds;
  final void Function(BookingSlot) onToggle;
  final bool Function(BookingSlot) isSlotPast;
  final void Function(BookingSlot)? onCancelBookedSlot;
  final Set<int>? cancellingSlotIds;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BookingSlot>>(
      future: futureSlots,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: MyApp.orange,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load slots.',
              style: GoogleFonts.nunitoSans(color: Colors.grey),
            ),
          );
        }

        final slots = (snapshot.data ?? []).where((s) => !isSlotPast(s)).toList();
        if (slots.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No slots available for this date.',
                style: GoogleFonts.nunitoSans(color: Colors.grey),
              ),
            ),
          );
        }

        return Wrap(
          spacing: 10, 
          runSpacing: 10,
          children: slots.map((slot) {
            final isSelected = selectedSlotIds.contains(slot.id);
            final isCancelling = cancellingSlotIds?.contains(slot.id) ?? false;

            // Variabel Warna
            Color bg;
            Color border;
            Color text;

            const double fixedFontSize = 14.0;
            const FontWeight fixedFontWeight = FontWeight.w800;

            // --- LOGIKA WARNA BARU ---

            // 1. SEDANG DIPILIH (Klik saat ini) -> OREN
            if (isSelected) {
              bg = const Color(0xFFFFEFE6); 
              border = MyApp.orange;       
              text = MyApp.orange;          
            } 
            // 2. SUDAH DIBOOKING SAYA (History) -> ABU-ABU (Sesuai Request)
            else if (slot.isBookedByUser) {
              // Kita buat abu-abu, tapi teksnya tetap gelap agar terlihat "bisa dicancel" (bukan disabled)
              bg = const Color(0xFFE5E7EB); // Background Abu
              border = const Color(0xFFD1D5DB); // Border Abu sedikit gelap
              text = MyApp.gumetalSlate; // Teks Gelap (Biar terbaca jelas)
            }
            // 3. DIBOOKING ORANG LAIN -> ABU-ABU MATI (Disabled)
            else if (slot.isBooked) {
              bg = const Color(0xFFE5E7EB);
              border = const Color(0xFFE5E7EB);
              text = const Color(0xFF9CA3AF); // Teks Abu pudar
            } 
            // 4. AVAILABLE -> PUTIH
            else {
              bg = Colors.white;
              border = MyApp.darkSlate; 
              text = MyApp.darkSlate;   
            }

            // Slot orang lain (abu-abu mati) tidak bisa diklik
            final bool isDisabled = slot.isBooked && !slot.isBookedByUser;

            return GestureDetector(
              onTap: (isCancelling || isDisabled)
                  ? null
                  : () {
                      if (slot.isBookedByUser && onCancelBookedSlot != null) {
                        onCancelBookedSlot!(slot);
                        return;
                      }
                      onToggle(slot);
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: ShapeDecoration(
                  color: bg,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: border),
                    borderRadius: BorderRadius.circular(50), 
                  ),
                  shadows: bg == Colors.white
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: isCancelling
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: slot.isBookedByUser ? MyApp.gumetalSlate : MyApp.orange,
                        ),
                      )
                    : Text(
                        '${slot.startTime} - ${slot.endTime}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunitoSans(
                          fontSize: fixedFontSize, 
                          fontWeight: fixedFontWeight, 
                          color: text,
                          height: 1.50,
                        ),
                      ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}