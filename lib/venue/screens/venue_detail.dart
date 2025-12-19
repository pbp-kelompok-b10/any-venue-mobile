import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:any_venue/main.dart';
import 'package:any_venue/widgets/confirmation_modal.dart';
import 'package:any_venue/widgets/toast.dart';
import 'package:any_venue/widgets/components/app_bar.dart';

import 'package:any_venue/venue/models/venue.dart';
import 'package:any_venue/venue/screens/venue_form.dart';
import 'package:any_venue/venue/widgets/venue_detail_widgets.dart';

import 'package:any_venue/review/screens/review_page.dart';
import 'package:any_venue/review/screens/review_form.dart';
import 'package:any_venue/review/models/review.dart';
import 'package:any_venue/review/widgets/review_list.dart';


class VenueDetail extends StatefulWidget {
  final Venue venue;
  const VenueDetail({super.key, required this.venue});

  @override
  State<VenueDetail> createState() => _VenueDetailState();
}

class _VenueDetailState extends State<VenueDetail> {
  late Venue _venue;
  bool _hasEdited = false;
  bool _isDeleting = false;

  List<Review> _reviews = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _venue = widget.venue;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchReviews();
    });
  }

  // --- API LOGIC ---
  Future<void> _fetchReviews() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('http://localhost:8000/review/json/venue/${_venue.id}/');
      if (mounted) {
        setState(() {
          List<dynamic> listJson = response;
          _reviews = listJson.map((d) => Review.fromJson(d)).toList();
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      debugPrint("Failed to fetch review: $e");
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _refreshData() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/venue/api/venue-detail-flutter/${_venue.id}/',
      );
      if (mounted) {
        setState(() => _venue = Venue.fromJson(response));
      }
    } catch (e) {
      debugPrint("Failed to refresh data: $e");
    }
  }

  Future<void> _handleDelete() async {
    final request = context.read<CookieRequest>();

    await ConfirmationModal.show(
      context,
      title: "Delete Venue?",
      message: "Are you sure you want to delete this venue? This action cannot be undone.",
      isDanger: true,
      confirmText: "Delete",
      icon: Icons.delete_outline_rounded,
      onConfirm: () async {
        final response = await request.post(
          'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/venue/api/delete-flutter/${_venue.id}/',
          {},
        );

        if (!mounted) return;

        if (response['status'] == 'success') {
          CustomToast.show(context, message: "Venue deleted!", isError: false);

          setState(() => _isDeleting = true);
          await Future.delayed(const Duration(milliseconds: 350));

          if (!mounted) return;
          Navigator.pop(context, true); // <-- ini yang dibaca VenueList untuk refresh
        } else {
          CustomToast.show(context, message: "Failed to delete.", isError: true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final String currentUsername = request.jsonData['username'] ?? '';
    final String currentRole = request.jsonData['role'] ?? 'USER';

    final bool isMyVenue = currentUsername == _venue.owner.username;
    final bool isUserRole = currentRole == 'USER';

    // Cari review user
    Review? userReview;
    if (!_isLoadingReviews && _reviews.isNotEmpty) {
      try {
        userReview = _reviews.firstWhere(
          (r) => r.user == currentUsername,
        );
      } catch (_) {
        // Tidak ditemukan review milik user ini
        userReview = null;
      }
    }

    return PopScope(
      canPop: _isDeleting,
      onPopInvoked: (didPop) {
        if (didPop) return;

        if (context.mounted) {
          Navigator.pop(context, _hasEdited);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: "Detail Venue"),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header Image
                    VenueHeaderImage(
                      imageUrl: 'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/venue/proxy-image/?url=${Uri.encodeComponent(_venue.imageUrl)}',
                    ),

                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2. Title
                          Text(
                            _venue.name,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF293241), height: 1.2
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 3. Info Card
                          VenueInfoCard(venue: _venue),
                          const SizedBox(height: 24),

                          // 4. Owner Profile
                          VenueOwnerSection(username: _venue.owner.username),
                          const SizedBox(height: 24),

                          // 5. Description & Location
                          _buildSectionTitle("Description"),
                          Text(
                            _venue.description,
                            style: const TextStyle(color: Colors.grey, height: 1.6, fontSize: 14),
                          ),
                          const SizedBox(height: 20),
                          _buildSectionTitle("Location"),
                          Text(
                            _venue.address,
                            style: const TextStyle(color: Colors.grey, height: 1.6, fontSize: 14),
                          ),
                          const SizedBox(height: 32),

                          // 6. Review Header
                          _buildReviewHeader(context),
                          
                          // 7. Review List
                          if (_isLoadingReviews)
                            const SizedBox(
                              height: 150,
                              child: Center(
                                child: CircularProgressIndicator(color: MyApp.orange),
                              ),
                            )
                          else if (_reviews.isEmpty)
                            Container(
                              height: 150,
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "No reviews for this venue yet.",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          else
                            ReviewList(
                              reviews: _reviews,
                              isHorizontal: true, 
                              scrollable: true,
                            ),
                          
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 8. Bottom Action Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: SafeArea(
                child: VenueActionButtons(
                  isMyVenue: isMyVenue,
                  isUserRole: isUserRole,
                  hasReviewed: userReview != null,
                  onDelete: _handleDelete,
                  onBook: () { /* Todo: Booking Logic */ },
                  onEdit: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VenueFormPage(venue: _venue)),
                    );
                    if (result == true) {
                      setState(() => _hasEdited = true);
                      await _refreshData();
                    }
                  },
                  onReview: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReviewFormPage(
                        venueId: userReview != null ? null : _venue.id,
                        existingReview: userReview,
                      )),
                    );
                    if (result == true && mounted) _fetchReviews();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
  
  Widget _buildReviewHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Customer Reviews", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewPage(venueId: _venue.id))),
          child: const Text("See all", style: TextStyle(fontSize: 13, color: MyApp.orange, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}