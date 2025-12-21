import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// --- MAIN & THEME ---
import 'package:any_venue/main.dart';

// --- WIDGETS ---
import 'package:any_venue/widgets/components/app_bar.dart';
import 'package:any_venue/widgets/components/search_bar.dart';
import 'package:any_venue/widgets/components/button.dart';
import 'package:any_venue/booking/widgets/booking_card.dart';
import 'package:any_venue/booking/screens/booking_screen.dart';

// --- MODELS ---
import '../models/booking.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  // 1. Search & Filter State
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  
  // false => upcoming, true => past
  bool _showPast = false;

  // 2. Data State
  List<Booking> _allBookings = [];
  List<Booking> _displayedBookings = [];
  bool _isLoading = true;
  
  // Navigation Guard
  final Set<int> _navigatingSlots = {};

  @override
  void initState() {
    super.initState();
    // Fetch data setelah frame pertama selesai dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBookings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- API Fetch Logic ---
  Future<void> _fetchBookings() async {
    final request = context.read<CookieRequest>();
    setState(() => _isLoading = true);

    final endpoint = _showPast
        ? 'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/booking/mybookings/past/json/'
        : 'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/booking/mybookings/upcoming/json/';

    try {
      final response = await request.get(endpoint);
      
      // Parsing logic
      // PBP Django Auth biasanya mengembalikan List dynamic jika JSON response-nya list
      // Kita perlu konversi ke JSON string dulu jika modelnya butuh raw json, 
      // atau parsing manual. Di sini saya asumsikan `bookingFromJson` butuh string.
      final jsonString = jsonEncode(response);
      final List<Booking> list = bookingFromJson(jsonString);

      if (mounted) {
        setState(() {
          _allBookings = list;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e) {
      debugPrint("Error fetching bookings: $e");
      if (mounted) {
        setState(() {
          _allBookings = [];
          _displayedBookings = [];
          _isLoading = false;
        });
      }
    }
  }

  // --- Logic Filtering (Search) ---
  void _applyFilters() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _displayedBookings = List.from(_allBookings);
      } else {
        _displayedBookings = _allBookings.where((booking) {
          // Search by Venue Name
          return booking.venue.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      }
    });
  }

  void _runSearch(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // --- Navigation Logic ---
  Future<void> _openBookingVenue(Booking booking) async {
    if (_navigatingSlots.contains(booking.slotId)) return;

    final request = context.read<CookieRequest>();
    setState(() {
      _navigatingSlots.add(booking.slotId);
    });

    try {
      final res = await request.get(
        'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/booking/slot-venue-flutter/${booking.slotId}/',
      );

      if (!mounted) return;

      if (res['status'] == 'success' && res['venue'] != null) {
        final v = res['venue'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingScreen(
              venueId: v['id'],
              venueName: v['name'],
              venuePrice: v['price'],
              venueAddress: v['address'],
              venueType: v['type'],
              // Pastikan handle konversi ke String dengan aman
              venueCategory: v['category']?.toString() ?? "Sport", 
              venueImageUrl: v['image_url'],
              initialDate: booking.slotDate,
              focusSlotId: booking.slotId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka venue.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan server.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _navigatingSlots.remove(booking.slotId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Sesuaikan dengan MyEventPage
      // 1. Custom App Bar
      appBar: const CustomAppBar(
        title: 'My Bookings',
        showBackButton: false,
      ),
      body: Column(
        children: [
          // 2. Search Bar Section
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            color: Colors.white,
            child: CustomSearchBar(
              controller: _searchController,
              hintText: "Search your booking...",
              readOnly: false,
              onChanged: _runSearch,
            ),
          ),

          // 3. Custom Tabs Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: _buildCustomTabs(),
          ),

          // 4. Booking List Section
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayedBookings.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                    itemCount: _displayedBookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final b = _displayedBookings[index];
                      return BookingCard(
                        booking: b,
                        onArrowTap: () => _openBookingVenue(b),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabs() {
    return Row(
      children: [
        // Tab Upcoming
        Expanded(
          child: CustomButton(
            text: 'Upcoming',
            // Jika sedang showPast, maka Upcoming outlined (inactive)
            isOutlined: _showPast, 
            color: MyApp.gumetalSlate,
            gradientColors: const [MyApp.darkSlate, MyApp.gumetalSlate],
            onPressed: () {
              if (_showPast) {
                setState(() {
                  _showPast = false;
                  _allBookings = []; // Clear list sementara loading
                  _displayedBookings = [];
                  _searchController.clear();
                  _searchQuery = "";
                });
                _fetchBookings();
              }
            },
          ),
        ),
        const SizedBox(width: 8), 
        // Tab Past
        Expanded(
          child: CustomButton(
            text: 'History',
            // Jika TIDAK showPast, maka History outlined (inactive)
            isOutlined: !_showPast,
            color: MyApp.gumetalSlate,
            gradientColors: const [MyApp.darkSlate, MyApp.gumetalSlate],
            onPressed: () {
              if (!_showPast) {
                setState(() {
                  _showPast = true;
                  _allBookings = [];
                  _displayedBookings = [];
                  _searchController.clear();
                  _searchQuery = "";
                });
                _fetchBookings();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? "No bookings found for '$_searchQuery'"
                  : _showPast
                      ? "No past bookings yet"
                      : "No upcoming bookings yet",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}