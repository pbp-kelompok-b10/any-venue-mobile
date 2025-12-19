import 'package:flutter/material.dart';
import 'package:any_venue/venue/models/venue.dart';
import 'package:any_venue/venue/widgets/venue_card.dart';
import 'package:any_venue/venue/screens/venue_detail.dart';

// Enum untuk menentukan tipe tampilan list
enum VenueListType {
  horizontalFeat, // Geser samping, random 5 (Home)
  verticalSmall, // List ke bawah, card kecil (Search)
  verticalLarge // List ke bawah, card besar (My Venue)
}

class VenueList extends StatefulWidget {
  final List<Venue> venues;
  final Function() onRefresh;
  final VenueListType listType; // Ganti bool isLarge dengan ini
  final bool scrollable;

  const VenueList({
    super.key,
    required this.venues,
    this.listType = VenueListType.horizontalFeat, // Default Home
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
      return const SizedBox.shrink();
    }

    switch (widget.listType) {
      case VenueListType.horizontalFeat:
        return _buildLargeHorizontalList();
      case VenueListType.verticalSmall:
        return _buildVerticalList(isCardSmall: true);
      case VenueListType.verticalLarge:
        return _buildVerticalList(isCardSmall: false);
    }
  }

  // ==========================================
  // LAYOUT 1: HORIZONTAL (GESER SAMPING)
  // - Randomize & Limit 5
  // ==========================================
  Widget _buildLargeHorizontalList() {
    final List<Venue> randomVenues = List<Venue>.from(widget.venues)..shuffle();
    final List<Venue> displayedVenues = randomVenues.take(5).toList();

    return SizedBox(
      height: 340,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: displayedVenues.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 260,
            child: VenueCard(
              venue: displayedVenues[index],
              isSmall: false, // Card Besar
              onTap: () => _navigateToDetail(displayedVenues[index]),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // LAYOUT 2 & 3: VERTICAL (LIST KE BAWAH)
  // - Bisa Small atau Large tergantung parameter
  // ==========================================
  Widget _buildVerticalList({required bool isCardSmall}) {
    return ListView.builder(
      physics: widget.scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: !widget.scrollable,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: widget.venues.length,
      itemBuilder: (context, index) {
        return VenueCard(
          venue: widget.venues[index],
          isSmall: isCardSmall, // Dinamis sesuai tipe
          onTap: () => _navigateToDetail(widget.venues[index]),
        );
      },
    );
  }

  // Helper Navigation
  Future<void> _navigateToDetail(Venue venue) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VenueDetail(venue: venue),
      ),
    );

    if (result == true) {
      widget.onRefresh();
    }
  }
}