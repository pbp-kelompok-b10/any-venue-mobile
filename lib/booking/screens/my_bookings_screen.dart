import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:any_venue/booking/widgets/booking_card.dart';
import 'package:any_venue/booking/widgets/booking_filter_tabs.dart';
import 'package:any_venue/booking/screens/booking_screen.dart';

import '../models/booking.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  // false => upcoming, true => past
  bool showPast = false;
  final Set<int> _navigatingSlots = {};

  Future<List<Booking>> _fetchBookings(CookieRequest request) async {
    final endpoint = showPast
        ? 'http://10.0.2.2:8000/booking/mybookings/past/json/'
        : 'http://10.0.2.2:8000/booking/mybookings/upcoming/json/';

    final response = await request.get(endpoint);
    final jsonString = jsonEncode(response);
    return bookingFromJson(jsonString);
  }

  Future<void> _openBookingVenue(CookieRequest request, Booking booking) async {
    if (_navigatingSlots.contains(booking.slotId)) return;

    setState(() {
      _navigatingSlots.add(booking.slotId);
    });

    try {
      final res = await request.get(
        'http://10.0.2.2:8000/booking/slot-venue-flutter/${booking.slotId}/',
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
              venueImageUrl: v['image_url'],
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
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              BookingFilterTabs(
                showPast: showPast,
                onChange: (val) => setState(() => showPast = val),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<Booking>>(
                  future: _fetchBookings(request),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Failed to load bookings'));
                    }
                    final items = snapshot.data ?? [];
                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          showPast
                              ? 'No past bookings yet'
                              : 'No upcoming bookings yet',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final b = items[index];
                        return BookingCard(
                          booking: b,
                          onArrowTap: () => _openBookingVenue(request, b),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
