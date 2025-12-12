import 'package:flutter/material.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/review/models/review.dart';

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Hapus width hardcoded (313) agar responsif mengikuti parent
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // Menambahkan shadow agar senada dengan VenueCard dan terlihat 'pop' di background putih
        boxShadow: [
          BoxShadow(
            color: MyApp.gumetalSlate.withOpacity(0.1),
            blurRadius: 10,
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
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: MyApp.darkSlate, // Menggunakan warna tema
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 28,
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
                        fontWeight: FontWeight.w600, // Sedikit lebih tebal (w500-w600)
                        height: 1.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      review.createdAt, // Asumsi format string sudah sesuai (e.g. DD-MM-YYYY)
                      style: const TextStyle(
                        color: Color(0xFF7A7A90), // Warna abu-abu dari Figma
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

          const SizedBox(height: 16), // Spacing antar Header dan Content

          // --- CONTENT: STARS & COMMENT ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Star Rating Row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Icon(
                      Icons.star_rounded,
                      size: 20,
                      // Logic: Jika index < rating, warna Orange. Jika tidak, abu-abu muda.
                      color: index < review.rating
                          ? MyApp.orange
                          : const Color(0xFFD3D5DD),
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 8), // Spacing kecil antara bintang dan teks
              
              // Comment Text
              Text(
                review.comment,
                style: const TextStyle(
                  color: Color(0xFF7A7A90),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ],
      ),
    );
  }
}