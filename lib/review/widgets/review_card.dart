import 'package:flutter/material.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/review/models/review.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final bool isCompact;

  const ReviewCard({
    super.key,
    required this.review,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
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
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: MyApp.darkSlate, // Menggunakan warna tema
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              
              // Nama & Tanggal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        // Logic: Jika index < rating, warna Orange. Jika tidak, abu-abu muda.
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                // LOGIC TRUNCATED:
                // Jika isCompact = true, batasi 3 baris. Jika tidak, null (bebas)
                maxLines: isCompact ? 3 : null, 
                // Jika isCompact = true, kasih "..." di ujung text
                overflow: isCompact ? TextOverflow.ellipsis : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}