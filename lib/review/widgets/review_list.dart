import 'package:flutter/material.dart';
import 'package:any_venue/review/models/review.dart';
import 'package:any_venue/review/widgets/review_card.dart';

class ReviewList extends StatelessWidget {
  final List<Review> reviews;
  final bool isHorizontal; // True = Mode "Customer Reviews" (Geser Samping)
  final bool scrollable; // Mengatur apakah list bisa discroll vertikal sendiri

  const ReviewList({
    super.key,
    required this.reviews,
    this.isHorizontal = false, // Default Vertikal (Halaman Detail)
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const SizedBox.shrink(); // Hide jika tidak ada review
    }

    if (isHorizontal) {
      return _buildHorizontalList();
    } else {
      return _buildVerticalList();
    }
  }

  // ==========================================
  // LAYOUT 1: HORIZONTAL (GESER SAMPING)
  // ==========================================
  Widget _buildHorizontalList() {
    return SizedBox(
      height: 240, // Tinggi area scroll (disesuaikan dengan konten card)
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: reviews.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 313,
            child: ReviewCard(review: reviews[index]),
          );
        },
      ),
    );
  }

  // ==========================================
  // LAYOUT 2: VERTICAL (LIST KE BAWAH)
  // - Digunakan di halaman "All Reviews"
  // ==========================================
  Widget _buildVerticalList() {
    return ListView.separated(
      physics: scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: !scrollable,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      itemCount: reviews.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return ReviewCard(review: reviews[index]);
      },
    );
  }
}