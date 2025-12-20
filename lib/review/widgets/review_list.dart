import 'package:flutter/material.dart';
import 'package:any_venue/review/models/review.dart';
import 'package:any_venue/review/widgets/review_card.dart';

class ReviewList extends StatelessWidget {
  final List<Review> reviews;
  final bool isHorizontal; // True = Mode "Customer Reviews" (Geser Samping)
  final bool scrollable;   // Mengatur apakah list bisa discroll vertikal sendiri

  final String? currentUsername;
  final Function(Review)? onEdit;
  final Function(Review)? onDelete;

  const ReviewList({
    super.key,
    required this.reviews,
    this.isHorizontal = false, // Default Vertikal (Halaman Detail)
    this.scrollable = true,
    this.currentUsername,
    this.onEdit,
    this.onDelete,
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

  // LAYOUT HORIZONTAL (list ke samping buat customer reviews di venue_detail)
  Widget _buildHorizontalList() {
    return SizedBox(
      height: 215,
      child: ListView.separated(
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(vertical: 24),
        scrollDirection: Axis.horizontal,
        itemCount: reviews.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final review = reviews[index];
          return SizedBox(
            width: 300,
            child: ReviewCard(
              review: review, 
              isCompact: true,
              currentUsername: currentUsername,
              onEdit: onEdit != null ? () => onEdit!(review) : null,
              onDelete: onDelete != null ? () => onDelete!(review) : null,
            ),
          );
        },
      ),
    );
  }

  // LAYOUT VERTICAL (list ke bawah buat review_page)
  Widget _buildVerticalList() {
    return ListView.separated(
      physics: scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: !scrollable,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      itemCount: reviews.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ReviewCard(
          review: review, 
          isCompact: false,
          currentUsername: currentUsername,
          onEdit: onEdit != null ? () => onEdit!(review) : null,
          onDelete: onDelete != null ? () => onDelete!(review) : null,
        );
      },
    );
  }
}