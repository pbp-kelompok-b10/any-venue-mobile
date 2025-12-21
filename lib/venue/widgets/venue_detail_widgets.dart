import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:any_venue/main.dart'; // Untuk akses warna
import 'package:any_venue/widgets/components/button.dart';
import 'package:any_venue/widgets/components/avatar.dart';
import 'package:any_venue/venue/models/venue.dart';

// --- WIDGET 1: HEADER IMAGE ---
class VenueHeaderImage extends StatelessWidget {
  final String imageUrl;

  const VenueHeaderImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 238,
      width: double.infinity,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.image_not_supported, color: Colors.grey),
              Text("No Image", style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET 2: INFO CARD (Price, Type, Category) ---
class VenueInfoCard extends StatelessWidget {
  final Venue venue;

  const VenueInfoCard({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: MyApp.gumetalSlate.withOpacity(0.3),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(Icons.attach_money, "Price", "Rp ${venue.price}"),
          _buildItem(Icons.stadium_rounded, "Type", venue.type),
          _buildItem(Icons.sports_tennis, "Category", venue.category.name),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: MyApp.gumetalSlate),
            const SizedBox(width: 2),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: MyApp.orange),
        ),
      ],
    );
  }
}

// --- WIDGET 3: OWNER SECTION ---
class VenueOwnerSection extends StatelessWidget {
  final String username;

  const VenueOwnerSection({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(
          initial: username.isNotEmpty ? username[0].toUpperCase() : "U",
          size: 48,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF293241)),
            ),
            const Text(
              "Owner",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

// --- WIDGET 4: ACTION BUTTONS ---
class VenueActionButtons extends StatelessWidget {
  final bool isMyVenue;
  final bool isUserRole;
  final bool hasReviewed;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onBook;
  final VoidCallback onReview;

  const VenueActionButtons({
    super.key,
    required this.isMyVenue,
    required this.isUserRole,
    required this.hasReviewed,
    required this.onDelete,
    required this.onEdit,
    required this.onBook,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    if (isMyVenue) {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              text: "Delete",
              isFullWidth: true,
              color: MyApp.orange,
              onPressed: onDelete,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: "Edit",
              isFullWidth: true,
              gradientColors: const [MyApp.gumetalSlate, MyApp.darkSlate],
              onPressed: onEdit,
            ),
          ),
        ],
      );
    } else if (isUserRole) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: CustomButton(
              text: "Booking Venue",
              isFullWidth: true,
              gradientColors: const [MyApp.gumetalSlate, MyApp.darkSlate],
              onPressed: onBook,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: CustomButton(
              text: hasReviewed ? "Edit Review" : "Add Review",
              isFullWidth: true,
              color: MyApp.orange,
              onPressed: onReview,
            ),
          ),
        ],
      );
    } else {
      return const SizedBox(
        height: 50,
        child: Center(
            child: Text("You are viewing as Owner",
                style: TextStyle(color: Colors.grey))),
      );
    }
  }
}