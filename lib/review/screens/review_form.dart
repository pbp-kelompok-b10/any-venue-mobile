import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:any_venue/main.dart';
import 'package:any_venue/widgets/components/button.dart';
import 'package:any_venue/widgets/components/app_bar.dart';
import 'package:any_venue/widgets/toast.dart';

import 'package:any_venue/review/models/review.dart';
import 'package:any_venue/venue/models/venue.dart';
import 'package:any_venue/venue/widgets/venue_card.dart';

class ReviewFormPage extends StatefulWidget {
  final int? venueId; // Null = Edit, Not Null = Create
  final Venue? venue;
  final Review? existingReview; // Null = Create, Not Null = Edit

  const ReviewFormPage({
    super.key, 
    this.venueId, 
    this.venue,
    this.existingReview
  });

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  final _formKey = GlobalKey<FormState>();

  // State Input
  int _rating = 0;
  String _comment = "";

  bool _validateRating = false;

  // Controller untuk Text Field agar bisa di-set initial value-nya
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();

    // Jika Mode Edit, isi form dengan data lama
    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating;
      _comment = widget.existingReview!.comment;
      _commentController.text = _comment;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEdit = widget.existingReview != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: isEdit ? "Edit Review" : "Write a Review"),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.venue != null) ...[
                VenueCard(
                  venue: widget.venue!,
                  isSmall: true,
                  // onTap: null,
                ),
                const SizedBox(height: 20),
              ],

              // STAR RATING SECTION
              Center(
                child: Column(
                  children: [
                    const Text(
                      "How was your experience?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MyApp.gumetalSlate,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                          iconSize: 40,
                          icon: Icon(
                            index < _rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: index < _rating
                                ? MyApp.orange
                                : Colors.grey.shade400,
                          ),
                          splashColor: MyApp.orange.withOpacity(0.2),
                          highlightColor: Colors.transparent,
                        );
                      }),
                    ),
                    // Validasi Visual untuk Rating
                    if (_validateRating && _rating == 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Please select a star rating",
                          style: TextStyle(
                            color: MyApp.orange,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // COMMENT SECTION
              _buildSectionLabel("Comment"),
              TextFormField(
                controller: _commentController,
                maxLength: 500,
                maxLines: 5,
                decoration: _inputDecoration(
                  "Share your experience here...",
                ),
                onChanged: (val) => _comment = val,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Comment cannot be empty";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // TOMBOL SAVE
              CustomButton(
                text: isEdit ? "Update Review" : "Submit Review",
                gradientColors: const [MyApp.gumetalSlate, MyApp.darkSlate],
                isFullWidth: true,
                onPressed: () async {
                  setState(() {
                    _validateRating = true;
                  });

                  // Validasi Form & Rating
                  if (_formKey.currentState!.validate() && _rating > 0) {
                    const String baseUrl =
                        "https://keisha-vania-anyvenue.pbp.cs.ui.ac.id";

                    String url = isEdit
                        ? '$baseUrl/review/edit-flutter/${widget.existingReview!.id}/'
                        : '$baseUrl/review/add-flutter/${widget.venueId}/';

                    // Kirim Data
                    final response = await request.postJson(
                      url,
                      jsonEncode({"rating": _rating, "comment": _comment}),
                    );

                    if (context.mounted) {
                      if (response['status'] == 'success') {
                        CustomToast.show(
                          context,
                          message: response['message'],
                          subMessage: isEdit
                              ? null
                              : "Thank you for your feedback!",
                          isError: false,
                        );
                        Navigator.pop(
                          context,
                          true,
                        ); // Return true agar halaman sebelumnya refresh
                      } else {
                        CustomToast.show(
                          context,
                          message: "Failed to submit review.",
                          subMessage: response['message'] ?? "Error occurred",
                          isError: true,
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: MyApp.gumetalSlate,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MyApp.darkSlate, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
