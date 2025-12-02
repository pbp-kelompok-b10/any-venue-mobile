import 'package:flutter/material.dart';
import 'package:any_venue/venue/models/venue.dart';
import 'package:any_venue/venue/widgets/venue_card.dart';
import 'package:any_venue/venue/screens/venue_detail.dart';

class VenueList extends StatelessWidget {
  final List<Venue> venues;
  final bool isLarge; // True = Horizontal & Random 5, False = Vertical & All
  final bool scrollable;

  const VenueList({
    super.key,
    required this.venues,
    this.isLarge = true, // Default mode Besar (Horizontal)
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    if (venues.isEmpty) {
      return const SizedBox.shrink(); // Jangan tampilkan apa-apa kalau data kosong
    }

    if (isLarge) {
      return _buildLargeHorizontalList();
    } else {
      return _buildSmallVerticalList();
    }
  }

  // ==========================================
  // LAYOUT 1: HORIZONTAL (GESER SAMPING)
  // - Randomize & Limit 5
  // ==========================================
  Widget _buildLargeHorizontalList() {
    final List<Venue> randomVenues = List<Venue>.from(venues)..shuffle();
    // Ambil 5 item atau seadanya jika data kurang dari 5
    final List<Venue> displayedVenues = randomVenues.take(5).toList();

    return SizedBox(
      height: 310, // Tinggi area scroll
      child: ListView.separated(
        // Padding horizontal agar item pertama & terakhir tidak mepet layar
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: displayedVenues.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 260, // Lebar fix agar ukuran card seragam
            child: VenueCard(
              venue: displayedVenues[index],
              isSmall: false, // Mode Besar
              onTap: () {
                // TODO: Arahkan ke Detail Page
              },
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // LAYOUT 2: VERTICAL (LIST KE BAWAH)
  // - Menampilkan SEMUA data
  // ==========================================
  Widget _buildSmallVerticalList() {
    return ListView.builder(
      physics: scrollable 
          ? const AlwaysScrollableScrollPhysics() 
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: !scrollable, 

      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: venues.length,
      itemBuilder: (context, index) {
        return VenueCard(
          venue: venues[index],
          isSmall: true, // Mode Kecil
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VenueDetail(venue: venues[index])),
            );
          },
        );
      },
    );
  }
}