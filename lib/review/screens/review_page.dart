import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:any_venue/main.dart'; // Untuk akses warna tema (MyApp)
import 'package:any_venue/review/models/review.dart';
import 'package:any_venue/review/widgets/review_list.dart';

class ReviewPage extends StatefulWidget {
  final int venueId; // ID Venue diperlukan untuk fetch review

  const ReviewPage({super.key, required this.venueId});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

enum ReviewFilter { all, my }

class _ReviewPageState extends State<ReviewPage> {
  List<Review> _reviews = [];
  bool _isLoading = true;
  ReviewFilter _selectedFilter = ReviewFilter.all; // Default filter: All Reviews

  @override
  void initState() {
    super.initState();
    // Fetch data setelah frame pertama dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchReviews();
    });
  }

  // Fungsi fetch data yang dinamis berdasarkan filter
  Future<void> _fetchReviews() async {
    final request = context.read<CookieRequest>();
    
    // Set loading true saat ganti filter
    setState(() {
      _isLoading = true;
    });

    try {
      String endpoint = "";

      if (_selectedFilter == ReviewFilter.all) {
        // Endpoint ambil SEMUA review untuk venue ini
        endpoint = 'http://localhost:8000/review/json/venue/${widget.venueId}/';
      } else {
        // Endpoint ambil review SAYA saja untuk venue ini
        endpoint = 'http://localhost:8000/review/json/venue/${widget.venueId}/my/';
      }

      final response = await request.get(endpoint);

      if (mounted) {
        setState(() {
          List<dynamic> listJson = response;
          _reviews = listJson.map((d) => Review.fromJson(d)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
      if (mounted) {
        setState(() {
          _reviews = []; // Kosongkan jika error
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih sesuai desain
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false, // Title di kiri (Android style default, atau sesuaikan)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: MyApp.gumetalSlate),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Reviews",
          style: TextStyle(
            color: MyApp.gumetalSlate,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.withOpacity(0.1),
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- FILTER SECTION ---
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: _buildFilterButton(),
          ),

          // --- LIST SECTION ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: MyApp.orange))
                : _reviews.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFilter == ReviewFilter.all
                                  ? "No reviews yet."
                                  : "You haven't reviewed this venue.",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ReviewList(
                        reviews: _reviews,
                        isHorizontal: false, // Mode Vertikal
                        scrollable: true,
                      ),
          ),
        ],
      ),
    );
  }

  // Widget Tombol Filter (Dropdown style)
  Widget _buildFilterButton() {
    return PopupMenuButton<ReviewFilter>(
      onSelected: (ReviewFilter result) {
        if (_selectedFilter != result) {
          setState(() {
            _selectedFilter = result;
          });
          _fetchReviews(); // Refetch data saat filter berubah
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<ReviewFilter>>[
        const PopupMenuItem<ReviewFilter>(
          value: ReviewFilter.all,
          child: Text('All Reviews'),
        ),
        const PopupMenuItem<ReviewFilter>(
          value: ReviewFilter.my,
          child: Text('My Review'),
        ),
      ],
      // Tombol pemicu popup
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_list_rounded, size: 18, color: MyApp.gumetalSlate),
            const SizedBox(width: 8),
            Text(
              _selectedFilter == ReviewFilter.all ? "All Reviews" : "My Review",
              style: const TextStyle(
                color: MyApp.gumetalSlate,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: MyApp.gumetalSlate),
          ],
        ),
      ),
    );
  }
}