import 'package:flutter/material.dart';
import 'package:any_venue/venue/models/venue.dart';
import 'package:any_venue/venue/widgets/venue_card.dart';
import 'package:any_venue/venue/screens/venue_detail.dart';

class VenueList extends StatefulWidget {
  final List<Venue> venues;
  final Function() onRefresh;
  final bool isLarge; // True = Horizontal & Random 5, False = Vertical & All
  final bool scrollable;

  const VenueList({
    super.key,
    required this.venues,
    this.isLarge = true, // Default mode Besar (Horizontal)
    this.scrollable = false,
    required this.onRefresh,
  });

  @override
  State<VenueList> createState() => _VenueListState();
}

class _VenueListState extends State<VenueList> {
  @override
  Widget build(BuildContext context) {
    if (widget.venues.isEmpty) {
      return const SizedBox.shrink(); // Jangan tampilkan apa-apa kalau data kosong
    }

    if (widget.isLarge) {
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
    final List<Venue> randomVenues = List<Venue>.from(widget.venues)..shuffle();
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
              venue: displayedVenues[index], // Gunakan displayedVenues agar index sesuai
              isSmall: false, // Mode Besar
              onTap: () async { // Tambah async
                // Tunggu hasil dari detail page
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VenueDetail(venue: displayedVenues[index]),
                  ),
                );

                // Jika ada sinyal refresh (true), panggil onRefresh milik parent
                if (result == true) {
                  widget.onRefresh();
                }
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
      physics: widget.scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: !widget.scrollable,

      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: widget.venues.length,
      itemBuilder: (context, index) {
        return VenueCard(
          venue: widget.venues[index],
          isSmall: true, // Mode Kecil
          onTap: () async { // Tambah async
            // Tunggu hasil dari detail page
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VenueDetail(venue: widget.venues[index]),
              ),
            );

            // Jika ada sinyal refresh (true), panggil onRefresh milik parent
            if (result == true) {
              widget.onRefresh();
            }
          },
        );
      },
    );
  }
}