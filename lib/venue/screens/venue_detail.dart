import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/venue/models/venue.dart';
import 'package:any_venue/widgets/components/label.dart';

class VenueDetail extends StatelessWidget {
  final Venue venue;

  const VenueDetail({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    // Ambil data user yang sedang login
    final String currentUsername = request.jsonData['username'] ?? '';
    final String currentRole = request.jsonData['role'] ?? 'no role'; 

    final bool isMyVenue = currentUsername == venue.owner.username;
    final bool isUser = !isMyVenue && currentRole != 'Owner'; 

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER IMAGE & BACK BUTTON
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: Colors.white,
                  leading: IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.arrow_back, color: MyApp.gumetalSlate),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeaderImage(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LABEL TYPE & CATEGORY
                        Row(
                          children: [
                            InfoLabel(
                              label: venue.category.name,
                              color: const Color(0xFFE3F2FD),
                              contentColor: MyApp.darkSlate,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              fontSize: 12,
                            ),
                            const SizedBox(width: 8),
                            InfoLabel(
                              label: venue.type,
                              color: MyApp.darkSlate,
                              contentColor: const Color(0xFFE3F2FD),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              fontSize: 12,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // NAMA VENUE
                        Text(
                          venue.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: MyApp.gumetalSlate,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // KOTAK INFO (HARGA & LOKASI)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: MyApp.gumetalSlate.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoColumn(
                                icon: Icons.attach_money,
                                label: "Harga",
                                value: "Rp ${venue.price}",
                                color: MyApp.orange,
                              ),
                              Container(height: 40, width: 1, color: Colors.grey.shade300),
                              _buildInfoColumn(
                                icon: Icons.location_on,
                                label: "Lokasi",
                                value: venue.city.name,
                                color: MyApp.darkSlate,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // OWNER SECTION
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: MyApp.darkSlate.withOpacity(0.1),
                              child: Text(
                                venue.owner.username[0].toUpperCase(),
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyApp.darkSlate),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  venue.owner.username,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const Text("Owner", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // DESCRIPTION
                        const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        Text(
                          venue.description,
                          style: const TextStyle(color: Colors.grey, height: 1.5),
                        ),
                        const SizedBox(height: 24),

                        // REVIEW SECTION (Placeholder)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Reviews", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            TextButton(onPressed: () {}, child: const Text("See All"))
                          ],
                        ),
                        const SizedBox(height: 100), 
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // BOTTOM ACTION BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: _buildActionButtons(context, request, isMyVenue, isUser),
        ),
      ),
    );
  }

  // --- LOGIC TOMBOL ---
  Widget _buildActionButtons(BuildContext context, CookieRequest request, bool isMyVenue, bool isUser) {
    // 1. Jika Pemilik Venue -> Edit & Delete
    if (isMyVenue) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _confirmDelete(context, request),
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text("Delete", style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {

              },
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text("Edit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: MyApp.darkSlate,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      );
    }
    
    // 2. Jika User Biasa -> Book & Review
    else if (isUser) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyApp.darkSlate,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Book Venue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: () {

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyApp.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Review", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    }

    // 3. Owner lain -> Kosong
    return const SizedBox.shrink();
  }

  // --- DELETE FUNCTION ---
  void _confirmDelete(BuildContext context, CookieRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Venue"),
        content: const Text("Are you sure you want to delete this venue? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); 
              final response = await request.post(
                'http://localhost:8000/venue/api/delete-flutter/${venue.id}/',
                {},
              );
              
              if (context.mounted) {
                if (response['status'] == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Venue deleted successfully")));
                  Navigator.pop(context); // Kembali ke list
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? "Failed to delete")));
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildHeaderImage() {
    if (venue.imageUrl.isEmpty) return Container(color: Colors.grey[200]);
    return Image.network(
      venue.imageUrl,
      fit: BoxFit.cover,
      headers: const {"User-Agent": "Mozilla/5.0"},
      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
    );
  }

  Widget _buildInfoColumn({required IconData icon, required String label, required String value, required Color color}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}