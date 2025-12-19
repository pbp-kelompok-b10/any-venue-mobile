import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:any_venue/main.dart';
import 'package:any_venue/widgets/confirmation_modal.dart';
import 'package:any_venue/widgets/components/button.dart';
import 'package:any_venue/widgets/toast.dart';

import 'package:any_venue/venue/models/venue.dart';
import 'package:any_venue/venue/screens/venue_form.dart';

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
  late Venue _venue; // Data venue yang aktif ditampilkan
  bool _hasEdited = false; // Penanda jika user melakukan edit

  List<Review> _reviews = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _venue = widget.venue;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      _fetchReviews(request);
    });
  }

  // --- Fungsi Fetch Review ---
  Future<void> _fetchReviews(CookieRequest request) async {
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
      debugPrint("Gagal ambil review: $e");
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  // Fungsi untuk refresh data single venue dari server
  Future<void> _refreshData(CookieRequest request) async {
    try {
      final response = await request.get(
        'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/venue/api/venue-detail-flutter/${_venue.id}/',
      );

      if (mounted) {
        setState(() {
          _venue = Venue.fromJson(response);
        });
      }
    } catch (e) {
      debugPrint("Gagal refresh data: $e");
    }
  }

  String get _imageUrl {
    return 'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/venue/proxy-image/?url=${Uri.encodeComponent(_venue.imageUrl)}';
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // ambil data dari user login
    final String currentUsername = request.jsonData['username'] ?? '';
    final String currentRole = request.jsonData['role'] ?? 'USER';

    // penentuan hak akses (Gunakan _venue, bukan widget.venue)
    final bool isMyVenue = currentUsername == _venue.owner.username;
    final bool isOwnerRole = currentRole == 'OWNER';
    final bool isUserRole = currentRole == 'USER';

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

    // Gunakan PopScope untuk menangani tombol Back (Android/AppBar)
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Saat back, kirim status _hasEdited ke halaman sebelumnya
        Navigator.pop(context, _hasEdited);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "Detail Venue",
            style: TextStyle(
              color: MyApp.gumetalSlate,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          elevation: 4,
          backgroundColor: Colors.white,
          shadowColor: MyApp.gumetalSlate.withOpacity(0.1),
          leading: IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_left_rounded,
              size: 32,
              color: MyApp.gumetalSlate,
            ),
            // Manual pop dengan membawa status edit
            onPressed: () => Navigator.pop(context, _hasEdited),
          ),
        ),

        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 360,
                      width: double.infinity,
                      child: _buildHeaderImage(),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // venue name
                          Text(
                            _venue.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF293241),
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // info box
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: MyApp.gumetalSlate.withOpacity(0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildInfoItem(
                                  Icons.attach_money,
                                  "Price",
                                  "Rp ${_venue.price}",
                                ),
                                _buildInfoItem(
                                  Icons.stadium_rounded,
                                  "Type",
                                  _venue.type,
                                ),
                                _buildInfoItem(
                                  Icons.sports_tennis,
                                  "Category",
                                  _venue.category.name,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // owner profile
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: MyApp.darkSlate,
                                child: Text(
                                  _venue.owner.username.isNotEmpty
                                      ? _venue.owner.username[0].toUpperCase()
                                      : "U",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _venue.owner.username,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF293241),
                                    ),
                                  ),
                                  const Text(
                                    "Owner",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // description
                          const Text(
                            "Description:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _venue.description,
                            style: const TextStyle(
                              color: Colors.grey,
                              height: 1.6,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            "Location:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _venue.address,
                            style: const TextStyle(
                              color: Colors.grey,
                              height: 1.6,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // review section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Customer Reviews",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  child: const Text(
                                    "See all",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: MyApp.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ReviewPage(venueId: _venue.id)),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        
                          // review list
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

            // bottom action bar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: _buildActionButtons(
                  context,
                  request,
                  isMyVenue,
                  isOwnerRole,
                  isUserRole,
                  userReview,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // tombol berdasarkan role
  Widget _buildActionButtons(
    BuildContext context,
    CookieRequest request,
    bool isMyVenue,
    bool isOwnerRole,
    bool isUserRole,
    Review? userReview,
  ) {
    if (isMyVenue) {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              text: "Delete",
              isFullWidth: true,
              color: MyApp.orange,
              onPressed: () => _confirmDelete(context, request),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: "Edit",
              isFullWidth: true,
              color: MyApp.darkSlate,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VenueFormPage(venue: _venue), // Kirim _venue
                  ),
                );

                // JIKA EDIT BERHASIL
                if (result == true) {
                  setState(() {
                    _hasEdited = true; // Tandai sudah diedit
                  });

                  if (context.mounted) {
                    await _refreshData(request);
                  }
                }
              },
            ),
          ),
        ],
      );
    }
    // user biasa -> book & review
    else if (isUserRole) {
      final bool hasReviewed = userReview != null;

      return Row(
        children: [
          Expanded(
            flex: 2,
            child: CustomButton(
              text: "Booking Venue",
              isFullWidth: true,
              color: MyApp.darkSlate,
              onPressed: () {
                // Booking logic
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: CustomButton(
              text: hasReviewed ? "Edit Review" : "Add Review",
              isFullWidth: true,
              color: MyApp.orange,
              onPressed: () async {
                // Panggil Form
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewFormPage(
                      // Jika Edit -> kirim existingReview
                      // Jika Add  -> kirim venueId
                      venueId: hasReviewed ? null : _venue.id,
                      existingReview: userReview, 
                    ),
                  ),
                );

                // Jika user berhasil submit (return true), refresh list review
                if (result == true && context.mounted) {
                  _fetchReviews(request);
                }
              },
            ),
          ),
        ],
      );
    } else {
      return const SizedBox(
        height: 50,
        child: Center(
          child: Text(
            "You are viewing this venue as an Owner.",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
  }

  // delete confirmation
  void _confirmDelete(BuildContext context, CookieRequest request) {
    ConfirmationModal.show(
      context,
      title: "Delete Venue?",
      message:
          "Are you sure you want to delete this venue? This action cannot be undone.",
      isDanger: true,
      confirmText: "Delete",
      icon: Icons.delete_outline_rounded,
      onConfirm: () async {
        final response = await request.post(
          'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/venue/api/delete-flutter/${_venue.id}/',
          {},
        );

        if (context.mounted) {
          Navigator.pop(context); // Tutup dialog

          if (response['status'] == 'success') {
            CustomToast.show(
              context,
              message: "Venue deleted!",
              subMessage: response['message'],
              isError: false,
            );

            Navigator.pop(context, true);
          } else {
            CustomToast.show(
              context,
              message: "Failed to delete.",
              subMessage: response['message'] ?? "An error ocurred.",
              isError: true,
            );
          }
        }
      },
    );
  }

  Widget _buildHeaderImage() {
    return Image.network(
      _imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.image_not_supported, color: Colors.grey),
              SizedBox(height: 4),
              Text(
                "No Image",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: MyApp.gumetalSlate),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: MyApp.orange,
          ),
        ),
      ],
    );
  }
}
