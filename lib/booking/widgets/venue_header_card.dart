import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:any_venue/main.dart'; 

class VenueHeaderCard extends StatelessWidget {
  const VenueHeaderCard({
    super.key,
    required this.venueName,
    required this.venuePrice,
    required this.venueAddress,
    required this.venueType,      // Contoh: "Indoor"
    required this.venueCategory,  // SEBELUMNYA sportType. Contoh: "Badminton"
    this.venueImageUrl,
  });

  final String venueName;
  final int venuePrice;
  final String venueAddress;
  final String venueType;
  final String venueCategory; 
  final String? venueImageUrl;

  String? _getProcessedUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    String rawUrl = url;
    if (url.contains('proxy-image') && url.contains('?url=')) {
      try {
        rawUrl = Uri.decodeFull(url.split('?url=')[1]);
      } catch (_) {}
    }
    if (!rawUrl.startsWith('http')) return null;
    return 'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/venue/proxy-image/?url=${Uri.encodeComponent(rawUrl)}';
  }

  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'IDR ',
      decimalDigits: 0,
    );

    final finalUrl = _getProcessedUrl(venueImageUrl);

    return Container(
      padding: const EdgeInsets.all(16), 
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. FOTO
          Container(
            width: 100, 
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFB4B4C1),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (finalUrl == null)
                  const Center(child: Icon(Icons.image_not_supported, color: Colors.white70)),
                if (finalUrl != null)
                  Image.network(
                    finalUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white70),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // 2. INFORMASI
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Venue
                Text(
                  venueName,
                  style: const TextStyle(
                    color: Color(0xFF293241),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 6),

                // Kategori & Tipe (Padel, Indoor, dll)
                // Menggunakan Wrap untuk menghindari overflow ke samping
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    // Kategori (Ex: Padel)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sports_baseball, size: 14, color: Color(0xFF293241)),
                        const SizedBox(width: 4),
                        // Gunakan Flexible agar text panjang tidak error
                        Flexible(
                          child: Text(
                            venueCategory,
                            style: const TextStyle(
                              color: Color(0xFFE9631A),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Tipe (Ex: Indoor)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.roofing, size: 14, color: Color(0xFF293241)),
                        const SizedBox(width: 4),
                        Text(
                          venueType,
                          style: const TextStyle(
                            color: Color(0xFFE9631A),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Alamat
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Color(0xFF7A7A90)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        venueAddress,
                        style: const TextStyle(
                          color: Color(0xFF7A7A90),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Harga
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: priceFormatter.format(venuePrice),
                        style: const TextStyle(
                          color: Color(0xFFE9631A),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const TextSpan(
                        text: ' /session',
                        style: TextStyle(
                          color: Color(0xFF7A7A90),
                          fontSize: 12,
                        ),
                      ),
                    ],
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