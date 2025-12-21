import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VenueHeaderCard extends StatelessWidget {
  const VenueHeaderCard({
    super.key,
    required this.venueName,
    required this.venuePrice,
    required this.venueAddress,
    required this.venueType,
    this.venueImageUrl,
  });

  final String venueName;
  final int venuePrice;
  final String venueAddress;
  final String venueType;
  final String? venueImageUrl;

  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'IDR ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFE5E7EB),
              image: venueImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(venueImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: venueImageUrl == null
                ? const Icon(Icons.image_outlined, color: Color(0xFF9CA3AF), size: 28)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venueName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.sports_tennis, size: 14, color: Color(0xFFE9631A)),
                    const SizedBox(width: 4),
                    Text(
                      venueType,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        venueAddress,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${priceFormatter.format(venuePrice)}/sesi',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE9631A),
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
