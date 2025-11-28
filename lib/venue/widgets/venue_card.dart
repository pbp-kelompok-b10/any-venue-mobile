import 'package:flutter/material.dart';
import 'package:any_venue/main.dart'; 
import 'package:any_venue/venue/models/venue.dart';
import 'package:any_venue/widgets/arrow_button.dart'; 

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
    return 'http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(venue.imageUrl)}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: MyApp.gumetalSlate.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // Switch Layout Besar / Kecil
        child: isSmall ? _buildSmallLayout() : _buildLargeLayout(),
      ),
    );
  }

  // --- LAYOUT BESAR ---
  Widget _buildLargeLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: _buildNetworkImage(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.name,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF293241)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${venue.price}",
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: MyApp.orange),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${venue.city.name}, ${venue.address}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
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
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: _buildNetworkImage(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  venue.name,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF293241)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${venue.price}",
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: MyApp.orange),
                ),
                const SizedBox(height: 4),
                Text(
                  venue.city.name,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
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
            child: const Center(child: CircularProgressIndicator()));
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.image_not_supported, color: Colors.grey),
              SizedBox(height: 4),
              Text("No Image", style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }
}