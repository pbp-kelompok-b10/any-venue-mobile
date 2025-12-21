import 'package:flutter/material.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/venue/models/venue.dart';
import 'package:any_venue/widgets/components/arrow_button.dart';
import 'package:any_venue/widgets/components/label.dart';

class VenueCard extends StatelessWidget {
  final Venue venue;
  final bool isSmall;
  final VoidCallback? onTap;

  const VenueCard({
    super.key,
    required this.venue,
    this.isSmall = false,
    this.onTap,
  });

  // Helper URL Proxy
  String get _imageUrl {
    return 'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/venue/proxy-image/?url=${Uri.encodeComponent(venue.imageUrl)}';
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: MyApp.gumetalSlate.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          // Switch Layout Besar / Kecil
          child: isSmall ? _buildSmallLayout() : _buildLargeLayout(),
        ),
      ),
    );
  }

  // --- LAYOUT BESAR ---
  Widget _buildLargeLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Stack(
            children: [
              // Gambar
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: _buildNetworkImage(),
                ),
              ),
            ],
          ),
        ),

        // 2. INFORMASI TEKS
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ), // Kiri, Atas, Kanan, Bawah
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Venue
                    Text(
                      venue.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MyApp.gumetalSlate,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Harga
                    Text(
                      "Rp ${venue.price}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: MyApp.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Lokasi
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            venue.city.name,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const ArrowButton(),
            ],
          ),
        ),
      ],
    );
  }

  // --- LAYOUT KECIL ---
  Widget _buildSmallLayout() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. IMAGE: Radius 10, Size 78x78
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0), 
            child: SizedBox(
              width: 78,
              height: 78, 
              child: _buildNetworkImage(),
            ),
          ),
          const SizedBox(width: 16), 
          
          // 2. TEXT INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  venue.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MyApp.gumetalSlate,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),

                // ROW INFO ORANGE (Price & Category)
                Row(
                  children: [
                    const Icon(Icons.payments_outlined, size: 16, color: MyApp.orange),
                    const SizedBox(width: 4),
                    Text(
                      'Rp ${venue.price}',
                      style: const TextStyle(
                        color: MyApp.orange, 
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    const Icon(Icons.sports_tennis_outlined, size: 16, color: MyApp.orange), 
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        venue.category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: MyApp.orange, 
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // ROW LOKASI (Grey)
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        venue.city.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          // 3. ARROW
          if (onTap != null)
          const ArrowButton(), 
        ],
      ),
    );
  }

  // --- IMAGE HELPER ---
  Widget _buildNetworkImage() {
    return Image.network(
      _imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator(color: MyApp.darkSlate)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.image_not_supported, color: Colors.grey),
              SizedBox(height: 4),
              Text(
                "No Image",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}
