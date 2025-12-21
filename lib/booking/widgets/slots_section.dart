import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:any_venue/main.dart'; // Import warna MyApp
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
              color: MyApp.darkSlate,
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

            // KONSISTENSI FONT:
            // Kita kunci font size dan weight agar tidak berubah saat diklik
            const double fixedFontSize = 14.0;
            const FontWeight fixedFontWeight = FontWeight.w800; // Menggunakan w800 agar sesuai request style Anda

            if (slot.isBooked) {
              // --- STATE: SUDAH DIBOOKING (DISABLED) ---
              bg = const Color(0xFFE5E7EB);
              border = const Color(0xFFE5E7EB);
              text = const Color(0xFF9CA3AF);
            } else if (slot.isBookedByUser || isSelected) {
              // --- STATE: SELECTED / BOOKED BY USER ---
              bg = const Color(0xFFFFEFE6); 
              border = MyApp.orange;       
              text = MyApp.orange;          
            } else {
              // --- STATE: TERSEDIA (DEFAULT) ---
              bg = Colors.white;
              border = MyApp.darkSlate; 
              text = MyApp.darkSlate;   
            }

            return GestureDetector(
              onTap: isCancelling
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
                        height: 20, // Height disesuaikan sedikit agar pas dengan font size 14
                        width: 20,
                        child: CircularProgressIndicator(
                          color: MyApp.darkSlate,
                        ),
                      )
                    : Text(
                        '${slot.startTime} - ${slot.endTime}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunitoSans(
                          fontSize: fixedFontSize, 
                          fontWeight: fixedFontWeight, 
                          color: text, // Hanya warna yang berubah
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