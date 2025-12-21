import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:any_venue/main.dart';
import 'package:any_venue/widgets/components/app_bar.dart';
import 'package:any_venue/widgets/components/search_bar.dart';
import 'package:any_venue/venue/widgets/venue_list.dart'; // Import VenueList yang baru direfactor
import 'package:any_venue/venue/models/venue.dart';

class MyVenuePage extends StatefulWidget {
  const MyVenuePage({super.key});

  @override
  State<MyVenuePage> createState() => MyVenuePageState();
}

class MyVenuePageState extends State<MyVenuePage> {
  // 1. Search Logic
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // 2. Data State
  List<Venue> _myVenues = []; // Semua venue milik user
  List<Venue> _filteredVenues = []; // Venue setelah difilter search
  bool _isLoading = true;

  Future<void> refresh() => _fetchMyVenues();

  @override
  void initState() {
    super.initState();
    // Fetch data saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMyVenues();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- API Fetch Logic ---
  Future<void> _fetchMyVenues() async {
    final request = context.read<CookieRequest>();
    final String currentUsername = request.jsonData['username'] ?? '';

    setState(() => _isLoading = true);

    try {
      // Ambil semua venue dari API
      final response = await request.get(
        'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/venue/api/venues-flutter/',
      );

      List<Venue> list = [];
      for (var d in response) {
        if (d != null) {
          Venue v = Venue.fromJson(d);
          // FILTER: Hanya ambil venue yang owner-nya sama dengan user login
          if (v.owner.username == currentUsername) {
            list.add(v);
          }
        }
      }

      if (mounted) {
        setState(() {
          _myVenues = list;
          _filteredVenues = list; // Awalnya tampilkan semua
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching my venues: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Search Logic (Local Filter) ---
  void _runSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredVenues = _myVenues;
      } else {
        _filteredVenues = _myVenues.where((venue) {
          return venue.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // 1. Custom App Bar 
      appBar: const CustomAppBar(
        title: "My Venues", 
        showBackButton: false
      ),

      body: Column(
        children: [
          // 2. Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: Colors.white,
            child: CustomSearchBar(
              controller: _searchController,
              hintText: "Search your venue...",
              readOnly: false,
              onChanged: _runSearch,
            ),
          ),

          // 3. List Venue
          Expanded(
            child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: MyApp.darkSlate))
            : _filteredVenues.isEmpty
                ? _buildEmptyState()
                : VenueList(
                    venues: _filteredVenues,
                    listType: VenueListType.verticalLarge, 
                    scrollable: true,
                    onRefresh: _fetchMyVenues,
                  ),
          ),
          const SizedBox(height: 46),
        ],
      ),
    );
  }

  // Widget Tampilan Kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.stadium_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _myVenues.isEmpty 
                ? "You haven't created any venues yet." 
                : "No venues found for '$_searchQuery'",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}