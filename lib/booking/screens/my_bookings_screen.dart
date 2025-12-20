import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/booking.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  // false => upcoming, true => past
  bool showPast = false;

  Future<List<Booking>> _fetchBookings(CookieRequest request) async {
    final endpoint = showPast
        ? 'http://10.0.2.2:8000/booking/mybookings/past/json/'
        : 'http://10.0.2.2:8000/booking/mybookings/upcoming/json/';

    final response = await request.get(endpoint);
    final jsonString = jsonEncode(response);
    return bookingFromJson(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _FilterTabs(
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
                        return _BookingCard(booking: b);
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

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
    required this.showPast,
    required this.onChange,
  });

  final bool showPast;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    final selectedColor = const LinearGradient(
      colors: [Color(0xFF3A5BA0), Color(0xFF1E2F5C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    // Border style is applied inline in the pills when not selected.

    Widget pill(String label, bool selected, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: selected ? selectedColor : null,
              color: selected ? null : Colors.white,
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      )
                    ]
                  : null,
              border: selected ? null : Border.all(color: const Color(0xFFCDD5DF)),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        pill('Upcoming Bookings', !showPast, () => onChange(false)),
        const SizedBox(width: 12),
        pill('Past Bookings', showPast, () => onChange(true)),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('MMM dd').format(booking.createdAt);
    final priceLabel = NumberFormat.currency(locale: 'id_ID', symbol: 'IDR ', decimalDigits: 0)
        .format(booking.totalPrice);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image placeholder area
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.image_outlined, color: Color(0xFF9CA3AF), size: 40),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date pill
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2E7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    dateLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFB923C)),
                  ),
                ),
                const SizedBox(width: 12),
                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking #${booking.id}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        priceLabel,
                        style: const TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                // Arrow
                const Icon(Icons.chevron_right, color: Color(0xFF1F2937)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
