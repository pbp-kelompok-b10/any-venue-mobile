import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:any_venue/main.dart';
import 'package:any_venue/widgets/components/button.dart';

import 'package:any_venue/venue/models/venue.dart';
// import 'package:any_venue/screens/venue_form.dart';

class VenueDetail extends StatelessWidget {
  final Venue venue;

  const VenueDetail({super.key, required this.venue});

  String get _imageUrl {
    return 'http://localhost:8000/venue/proxy-image/?url=${Uri.encodeComponent(venue.imageUrl)}';
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    // ambil data dari user login
    final String currentUsername = request.jsonData['username'] ?? '';
    final String currentRole = request.jsonData['role'] ?? 'User'; 

    // penentuan hak akses
    final bool isMyVenue = currentUsername == venue.owner.username;
    final bool isOwnerRole = currentRole == 'Owner';
    final bool isUserRole = currentRole == 'User' || currentRole == 'user'; 

    return Scaffold(
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
          icon: const Icon(Icons.keyboard_arrow_left_rounded, size:32, color: MyApp.gumetalSlate),
          onPressed: () => Navigator.pop(context),
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
                          venue.name,
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
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                              _buildInfoItem(Icons.attach_money, "Price", "Rp ${venue.price}"),
                              _buildInfoItem(Icons.house, "Type", venue.type),
                              _buildInfoItem(Icons.sports_tennis, "Category", venue.category.name),
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
                                venue.owner.username.isNotEmpty ? venue.owner.username[0].toUpperCase() : "U",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  venue.owner.username,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF293241)),
                                ),
                                const Text("Owner", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // description
                        const Text("Description:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          venue.description,
                          style: const TextStyle(color: Colors.grey, height: 1.6, fontSize: 14),
                        ),
                        const SizedBox(height: 20),

                        const Text("Location:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          venue.address,
                          style: const TextStyle(color: Colors.grey, height: 1.6, fontSize: 14),
                        ),
                        const SizedBox(height: 32),

                        // review section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Customer Reviews", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            MouseRegion(
                              cursor: SystemMouseCursors.click, // Ubah kursor jadi tangan
                              child: GestureDetector(
                                // onTap: ,
                                child: const Text(
                                  "See all",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: MyApp.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // TODO: tambah list review di sini
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
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
              ],
            ),
            child: SafeArea(
              child: _buildActionButtons(context, request, isMyVenue, isOwnerRole, isUserRole),
            ),
          ),
        ],
      ),
    );
  }

  // tombol berdasarkan role
  Widget _buildActionButtons(BuildContext context, CookieRequest request, bool isMyVenue, bool isOwnerRole, bool isUserRole) {
    // owner venue -> edit & delete
    if (isMyVenue) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _confirmDelete(context, request),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Ke Form Edit (Bawa data venue)
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => VenueFormPage(venue: venue)),
                // );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyApp.darkSlate,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Edit Venue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    } 
    
    // user biasa -> book & review
    else if (isUserRole || (!isOwnerRole && !isUserRole)) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: CustomButton(
              text: "Booking Venue",
              isFullWidth: true,
              color: MyApp.darkSlate,
              onPressed: () {
                // TODO: arahin ke page booking
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => ),
                // );
              },
            ),
          ),
        
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: CustomButton(
              text: "Add Review",
              isFullWidth: true,
              color: MyApp.orange,
              onPressed: () {
                // TODO: arahin ke page review
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => ),
                // );
              },
            ),
          ),
        ],
      );
    }

    // owner lain (bukan pny dia) -> kosong
    else {
      return const SizedBox(height: 50, child: Center(child: Text("You are viewing this venue as an Owner.", style: TextStyle(color: Colors.grey))));
    }
  }

  // delete confirmation
  void _confirmDelete(BuildContext context, CookieRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Venue"),
        content: const Text("Are you sure you want to delete this venue? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
              
              // Call API
              // GANTI 10.0.2.2 dengan IP jika di HP Fisik
              final response = await request.post(
                'http://localhost:8000/venue/api/delete-flutter/${venue.id}/',
                {},
              );

              if (context.mounted) {
                if (response['status'] == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Venue deleted successfully")));
                  Navigator.pop(context); // Balik ke halaman list
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? "Failed")));
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
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
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MyApp.orange),
        ),
      ],
    );
  }
}