import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:any_venue/booking/models/booking.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking, this.onArrowTap});

  final Booking booking;
  final VoidCallback? onArrowTap;

  @override
  Widget build(BuildContext context) {
    final slotDateLabel = DateFormat('MMM dd, yyyy').format(booking.slotDate);
    final createdLabel = DateFormat('MMM dd').format(booking.createdAt);
    final priceLabel = NumberFormat.currency(locale: 'id_ID', symbol: 'IDR ', decimalDigits: 0)
        .format(booking.totalPrice);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 170,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                alignment: Alignment.center,
                child: booking.venue.imageUrl == null || booking.venue.imageUrl!.isEmpty
                    ? const Icon(Icons.image_outlined, color: Color(0xFF9CA3AF), size: 40)
                    : ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          booking.venue.imageUrl!,
                          height: 170,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2E7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    createdLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFB923C),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.venue.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.venue.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$slotDateLabel • ${booking.startTime} - ${booking.endTime}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        priceLabel,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: onArrowTap,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: const Icon(Icons.chevron_right, color: Color(0xFF1F2937)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
