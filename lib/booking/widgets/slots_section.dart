import 'package:flutter/material.dart';
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
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Gagal memuat jadwal.'),
          );
        }

        final slots = (snapshot.data ?? []).where((s) => !isSlotPast(s)).toList();
        if (slots.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Tidak ada jadwal tersedia untuk tanggal ini.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) {
            final isSelected = selectedSlotIds.contains(slot.id);
            final isCancelling = cancellingSlotIds?.contains(slot.id) ?? false;

            Color bg;
            Color border;
            Color text;

            if (slot.isBooked) {
              bg = const Color(0xFFE5E7EB);
              border = const Color(0xFFE5E7EB);
              text = const Color(0xFF9CA3AF);
            } else if (slot.isBookedByUser || isSelected) {
              bg = const Color(0xFFE9631A);
              border = const Color(0xFFE9631A);
              text = Colors.white;
            } else {
              bg = Colors.white;
              border = const Color(0xFF315672);
              text = const Color(0xFF315672);
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
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: border, width: 1.2),
                  boxShadow: bg == Colors.white
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
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: bg == Colors.white ? const Color(0xFFE9631A) : Colors.white,
                        ),
                      )
                    : Text(
                        '${slot.startTime} - ${slot.endTime}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: text,
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
