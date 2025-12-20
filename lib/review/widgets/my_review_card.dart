import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/review/models/review.dart';

class MyReviewCard extends StatefulWidget {
  final Review review;
  final bool isCompact;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MyReviewCard({
    super.key,
    required this.review,
    this.isCompact = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<MyReviewCard> createState() => _MyReviewCardState();
}

class _MyReviewCardState extends State<MyReviewCard> {
  // State untuk data visual tambahan dari API Venue
  String? _finalImageUrl;
  String? _venueCity;
  String? _venueAddress;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchVenueDetails();
    });
  }

  Future<void> _fetchVenueDetails() async {
    final request = context.read<CookieRequest>();
    try {
      final url = 'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/venue/api/venue-detail-flutter/${widget.review.venueId}/';
      final response = await request.get(url);
      
      String? rawUrl = response['image_url'];
      String? proxyUrl;
      if (rawUrl != null && rawUrl.isNotEmpty) {
        proxyUrl = 'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/venue/proxy-image/?url=${Uri.encodeComponent(rawUrl)}';
      }

      String? cityName;
      if (response['city'] != null && response['city'] is Map) {
         cityName = response['city']['name'];
      }
      
      String? address = response['address'];

      if (mounted) {
        setState(() {
          _finalImageUrl = proxyUrl;
          _venueCity = cityName;
          _venueAddress = address;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading venue details: $e");
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;

    // --- PERUBAHAN UTAMA DI SINI ---
    // Menggunakan Container + BoxDecoration untuk Custom BoxShadow
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Shadow custom sesuai request kamu
          BoxShadow(
            color: MyApp.gumetalSlate.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // ClipRRect diperlukan agar gambar banner tidak keluar dari rounded corner
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN : GAMBAR VENUE (BANNER) ---
            Stack(
              children: [
                Container(
                  height: 160, 
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: _isLoadingData
                      ? const Center(child: CircularProgressIndicator())
                      : (_finalImageUrl != null)
                          ? Image.network(
                              _finalImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                            )
                          : const Center(
                              child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                ),
              ],
            ),

            // --- BAGIAN : INFO VENUE & REVIEW ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Nama Venue & Menu Option
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.venueName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: MyApp.gumetalSlate,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // Lokasi (City / Address)
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _venueCity ?? _venueAddress ?? "Unknown Location",
                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Menu Edit/Delete
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.more_horiz, color: MyApp.darkSlate),
                        onSelected: (val) {
                          if (val == 'edit') widget.onEdit?.call();
                          if (val == 'delete') widget.onDelete?.call();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20, color: MyApp.darkSlate),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: MyApp.orange),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Divider(height: 24, thickness: 1, color: Color(0xFFF0F0F0)),

                  // Bintang Rating
                  Row(
                    children: [
                      ...List.generate(5, (index) => Icon(
                        Icons.star_rounded,
                        size: 20,
                        color: index < review.rating ? MyApp.orange : Colors.grey.shade300,
                      )),
                      const SizedBox(width: 8),
                      Text(
                        "${review.rating}.0",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: MyApp.gumetalSlate),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Komentar User
                  Text(
                    review.comment,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    maxLines: widget.isCompact ? 3 : null,
                    overflow: widget.isCompact ? TextOverflow.ellipsis : null,
                  ),

                  const SizedBox(height: 12),

                  // Tanggal Review
                  Row(
                    children: [
                      Text(
                        review.createdAt,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                      if (review.createdAt != review.lastModified)
                        Text(' • Edited', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}