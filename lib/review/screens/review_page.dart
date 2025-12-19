import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:any_venue/main.dart';

import 'package:any_venue/review/models/review.dart';
import 'package:any_venue/review/widgets/review_list.dart';
import 'package:any_venue/review/screens/review_form.dart';

import 'package:any_venue/widgets/components/app_bar.dart';
import 'package:any_venue/widgets/confirmation_modal.dart';

class ReviewPage extends StatefulWidget {
  final int venueId; 

  const ReviewPage({super.key, required this.venueId});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

enum ReviewFilter { all, my }

class _ReviewPageState extends State<ReviewPage> {
  List<Review> _reviews = [];
  bool _isLoading = true;
  ReviewFilter _selectedFilter = ReviewFilter.all;
  int? _selectedRating;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchReviews();
    });
  }

  Future<void> _fetchReviews() async {
    final request = context.read<CookieRequest>();
    
    setState(() {
      _isLoading = true;
    });

    try {
      String endpoint = "";
      if (_selectedFilter == ReviewFilter.all) {
        endpoint = 'http://localhost:8000/review/json/venue/${widget.venueId}/';
        if (_selectedRating != null) {
          endpoint += '?rating=$_selectedRating';
        }
      } else {
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
          _reviews = []; 
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleDeleteReview(Review review, CookieRequest request) async {
    ConfirmationModal.show(
      context,
      title: "Delete Review?",
      message: "Are you sure you want to delete your review?",
      isDanger: true,
      confirmText: "Delete",
      icon: Icons.delete_outline_rounded,
      onConfirm: () async {
        final response = await request.post(
          'http://localhost:8000/review/delete-flutter/${review.id}/',
          {},
        );

        if (context.mounted) {
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Review deleted successfully")),
            );
            _fetchReviews(); // Panggil fungsi fetch yang sudah ada di ReviewPage
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['message'] ?? "Failed")),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final String? currentUsername = request.jsonData['username'] ?? '';
    bool isRatingDisabled = _selectedFilter == ReviewFilter.my;

    // Filter data dari _reviews berdasarkan bintang yang dipilih
    final filteredReviews = _reviews.where((review) {
      if (_selectedFilter == ReviewFilter.all && _selectedRating != null) {
        return review.rating == _selectedRating; 
      }
      return true; // Tampilkan semua jika tidak ada filter bintang
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Reviews"), 
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- FILTER SECTION ---
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton(
                    label: "Show",
                    selectedValue: Text(
                      _selectedFilter == ReviewFilter.all ? "All Reviews" : "My Review",
                      style: TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.w600, 
                        fontSize: 13
                      ),
                    ),
                    onTap: () => _showFilterModal(),
                    isActive: true,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterButton(
                    label: "Rating",
                    selectedValue: _selectedRating != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              _selectedRating!,
                              (index) => const Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: Colors.white, // Warna bintang saat aktif
                              ),
                            ),
                          )
                        : Text(
                            "Rating",
                            style: TextStyle(
                              color: isRatingDisabled ? Colors.grey.shade400 : Colors.grey[700]!,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ), 
                    onTap: isRatingDisabled ? null : () => _showRatingFilterModal(),
                    isActive: _selectedRating != null,
                    isDisabled: isRatingDisabled,
                    icon: Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: MyApp.orange))
                : filteredReviews.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey[300]),
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
                        reviews: filteredReviews,
                        isHorizontal: false,
                        scrollable: true,

                        currentUsername: currentUsername,
    
                        onEdit: (review) async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewFormPage(
                                existingReview: review,
                              ),
                            ),
                          );
                          if (result == true) {
                            _fetchReviews(); // Refresh list setelah edit
                          }
                        },
                        
                        onDelete: (review) {
                          _handleDeleteReview(review, request);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // --- HELPER: FILTER BUTTON & MODAL ---
  Widget _buildFilterButton({
    required String label,
    required Widget selectedValue,
    required VoidCallback? onTap,
    bool isActive = false,
    bool isDisabled = false,
    IconData icon = Icons.keyboard_arrow_down,
  }) {
    Color bgColor = isDisabled ? Colors.grey.shade100 : (isActive ? MyApp.darkSlate : Colors.white);
    Color contentColor = isDisabled ? Colors.grey.shade400 : (isActive ? Colors.white : Colors.grey[700]!);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDisabled ? Colors.transparent : (isActive ? MyApp.darkSlate : Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            selectedValue,
            const SizedBox(width: 4),
            Icon(icon, size: 16, color: contentColor),
          ],
        ),
      ),
    );
  }

  // --- MODAL: SELECT VIEW (ALL OR MY REVIEW) ---
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select View",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Tombol Clear (Opsional, di sini untuk reset ke All)
                  if (_selectedFilter == ReviewFilter.my)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = ReviewFilter.all;
                        });
                        _fetchReviews();
                        Navigator.pop(context);
                      },
                      child: const Text("Reset"),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildChoiceChip(
                    label: Text("All Reviews"),
                    isSelected: _selectedFilter == ReviewFilter.all,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilter = ReviewFilter.all);
                      _fetchReviews();
                      Navigator.pop(context);
                    },
                  ),
                  _buildChoiceChip(
                    label: Text("My Review"),
                    isSelected: _selectedFilter == ReviewFilter.my,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = ReviewFilter.my;
                          _selectedRating = null; // Otomatis reset bintang sesuai permintaan
                        });
                      }
                      _fetchReviews();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // --- MODAL: SELECT RATING (1-5 STARS) ---
  void _showRatingFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select Rating",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_selectedRating != null)
                    TextButton(
                      onPressed: () {
                        setState(() => _selectedRating = null);
                        Navigator.pop(context);
                      },
                      child: const Text("Clear"),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [1, 2, 3, 4, 5].map((star) {
                  return _buildChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        star,
                        (index) => Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: _selectedRating == star ? MyApp.orange : Colors.grey[600],
                        ),
                      ),
                    ),
                    isSelected: _selectedRating == star,
                    onSelected: (selected) {
                      setState(() => _selectedRating = selected ? star : null);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // --- HELPER: UNIFORM CHOICE CHIP STYLE ---
  Widget _buildChoiceChip({
    required Widget label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return ChoiceChip(
      label: label,
      selected: isSelected,
      selectedColor: MyApp.orange.withOpacity(0.2),
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        color: isSelected ? MyApp.orange : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: onSelected,
    );
  }
}