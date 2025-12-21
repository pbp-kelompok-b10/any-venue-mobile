import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:any_venue/main.dart';

import 'package:any_venue/review/models/review.dart';
import 'package:any_venue/review/widgets/my_review_list.dart';
import 'package:any_venue/review/screens/review_form.dart';

import 'package:any_venue/widgets/components/app_bar.dart';
import 'package:any_venue/widgets/confirmation_modal.dart';
import 'package:any_venue/widgets/toast.dart';

class MyReviewPage extends StatefulWidget {
  const MyReviewPage({super.key});

  @override
  State<MyReviewPage> createState() => _MyReviewPageState();
}

class _MyReviewPageState extends State<MyReviewPage> {
  List<Review> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMyReviews();
    });
  }

  Future<void> _fetchMyReviews() async {
    final request = context.read<CookieRequest>();

    setState(() {
      _isLoading = true;
    });

    try {
      const String endpoint =
          'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/review/json/my/';

      final response = await request.get(endpoint);

      if (mounted) {
        setState(() {
          List<dynamic> listJson = response;
          _reviews = listJson.map((d) => Review.fromJson(d)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching my reviews: $e");
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
      title: "Delete Review",
      message: "Are you sure you want to delete this review?",
      isDanger: true,
      confirmText: "Delete",
      icon: Icons.delete_outline,
      onConfirm: () async {
        final response = await request.post(
          'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/review/delete-flutter/${review.id}/',
          {},
        );

        if (context.mounted) {
          if (response['status'] == 'success') {
            CustomToast.show(
              context,
              message: response['message'],
              isError: false,
            );
            _fetchMyReviews(); // Refresh list setelah delete
          } else {
            CustomToast.show(
              context,
              message: "Failed to delete review.",
              subMessage: response['message'] ?? "Error occurred.",
              isError: true,
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "My Reviews", showBackButton: false),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: MyApp.darkSlate),
            )
          : _reviews.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 48,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "You haven't written any reviews yet.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : MyReviewList(
                  reviews: _reviews,
                  scrollable: true,
                  currentUsername: currentUsername,
                  onEdit: (review) async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ReviewFormPage(existingReview: review),
                      ),
                    );
                    if (result == true) {
                      _fetchMyReviews(); 
                    }
                  },
                  onDelete: (review) {
                    _handleDeleteReview(review, request);
                  },
                ),
    );
  }
}