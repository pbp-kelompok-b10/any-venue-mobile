import 'package:flutter/material.dart';
import 'package:any_venue/review/models/review.dart';
import 'package:any_venue/review/widgets/my_review_card.dart';

class MyReviewList extends StatelessWidget {
  final List<Review> reviews;
  final bool scrollable;   // Mengatur apakah list bisa discroll vertikal sendiri

  final String? currentUsername;
  final Function(Review)? onEdit;
  final Function(Review)? onDelete;

  const MyReviewList({
    super.key,
    required this.reviews, 
    this.scrollable = true,
    this.currentUsername,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const SizedBox.shrink(); 
    }

    return _buildVerticalList();
  }

  // LAYOUT VERTICAL (list ke bawah buat review_page)
  Widget _buildVerticalList() {
    return ListView.separated(
      physics: scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: !scrollable,
      
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      
      itemCount: reviews.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return MyReviewCard(
          review: review, 
          isCompact: false,
          onEdit: onEdit != null ? () => onEdit!(review) : null,
          onDelete: onDelete != null ? () => onDelete!(review) : null,
        );
      },
    );
  }
}