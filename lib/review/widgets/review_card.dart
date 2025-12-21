import 'package:flutter/material.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/review/models/review.dart';
import 'package:any_venue/widgets/components/avatar.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final bool isCompact;

  final String? currentUsername; 
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReviewCard({
    super.key,
    required this.review,
    this.isCompact = false,
    this.currentUsername,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOwner = currentUsername != null && review.user == currentUsername;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER: AVATAR & USER INFO ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Circle
              UserAvatar(
                initial: review.user.isNotEmpty ? review.user[0].toUpperCase() : 'U',
                size: 48,
              ),
              const SizedBox(width: 12),
              
              // Nama & Tanggal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row (
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          review.user,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        if (isOwner)
                          Text(
                            " (You)",
                            style: const TextStyle(
                              color: MyApp.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                            ),
                          ),
                      ],
                    ),

                    Text(
                      review.createdAt,
                      style: const TextStyle(
                        color: Color(0xFF7A7A90),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Untuk menu Edit/Delete, hanya muncul jika isOwner bernilai true
              if (isOwner) 
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Color(0xFF7A7A90),
                  ),
                  padding: EdgeInsets.zero,
                  offset: const Offset(0, 40),
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(12),
                  // ),
                  onSelected: (String value) {
                    if (value == 'edit') {
                      onEdit?.call();
                    } else if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      height: 36,
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      height: 36,
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 12),

          // --- CONTENT: STARS & COMMENT ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Star Rating Row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(5, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 1.0),
                      child: Icon(
                        Icons.star_rounded,
                        size: 23,
                        color: index < review.rating
                            ? MyApp.orange
                            : const Color(0xFFD3D5DD),
                      ),
                    );
                  }),
                  
                  SizedBox(width: 3),

                  Text(
                    review.createdAt == review.lastModified ? '' : ' (edited)',
                    style: const TextStyle(
                      color: Color(0xFF7A7A90),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Review Comment
              Text(
                review.comment,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                textAlign: TextAlign.left,
                maxLines: isCompact ? 2 : null, 
                overflow: isCompact ? TextOverflow.ellipsis : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}