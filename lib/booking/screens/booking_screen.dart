import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:any_venue/widgets/components/button.dart';
import 'package:any_venue/booking/widgets/booking_calendar.dart';
import 'package:any_venue/booking/widgets/slots_section.dart';
import 'package:any_venue/booking/widgets/summary_box.dart';
import 'package:any_venue/booking/widgets/venue_header_card.dart';
import 'package:any_venue/venue/screens/venue_page.dart';
import 'package:any_venue/widgets/confirmation_modal.dart';
import 'package:any_venue/widgets/toast.dart';
import 'package:any_venue/widgets/main_navigation.dart';

import '../models/booking_slot.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({
    super.key,
    required this.venueId,
    required this.venueName,
    required this.venuePrice,
    required this.venueAddress,
    required this.venueType,
    this.venueImageUrl,
  });

  final int venueId;
  final String venueName;
  final int venuePrice;
  final String venueAddress;
  final String venueType;
  final String? venueImageUrl;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  final Set<int> _selectedSlotIds = {};
  final Set<int> _cancellingSlotIds = {};
  bool _isSubmitting = false;

  Future<List<BookingSlot>> _fetchSlots(CookieRequest request) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final url = 'http://10.0.2.2:8000/booking/slots/${widget.venueId}/?date=$dateStr';

    final response = await request.get(url);

    final jsonString = jsonEncode(response);
    return bookingSlotFromJson(jsonString);
  }

  int get _totalPrice => _selectedSlotIds.length * widget.venuePrice;

  void _selectDate(DateTime day) {
    final today = DateTime.now();
    // Prevent selecting past days
    if (day.isBefore(DateTime(today.year, today.month, today.day))) return;

    setState(() {
      _selectedDate = day;
      _visibleMonth = DateTime(day.year, day.month);
      _selectedSlotIds.clear();
    });
  }

  void _toggleSlot(BookingSlot slot) {
    if (slot.isBooked || slot.isBookedByUser) return;

    if (_isSlotPast(slot)) return;

    setState(() {
      if (_selectedSlotIds.contains(slot.id)) {
        _selectedSlotIds.remove(slot.id);
      } else {
        _selectedSlotIds.add(slot.id);
      }
    });
  }

  bool _isSlotPast(BookingSlot slot) {
    final today = DateTime.now();
    if (!DateUtils.isSameDay(_selectedDate, today)) return false;

    final now = TimeOfDay.fromDateTime(today);
    final slotStart = _parseTime(slot.startTime);
    // Hide slot if already started
    return slotStart.hour < now.hour || (slotStart.hour == now.hour && slotStart.minute <= now.minute);
  }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(":");
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> _submitBooking(CookieRequest request) async {
    if (_selectedSlotIds.isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final url = 'http://10.0.2.2:8000/booking/create-flutter/';
      final response = await request.postJson(
        url,
        jsonEncode({
          'slots': _selectedSlotIds.toList(),
        }),
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        final serverTotal = response['total'] ?? _totalPrice;
        CustomToast.show(
          context,
          message: 'Booking berhasil!',
          subMessage: 'Total dibayar: IDR ${serverTotal.toString()}',
        );
        setState(() {
          _selectedSlotIds.clear();
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const VenuePage()),
          (route) => false,
        );
      } else {
        CustomToast.show(
          context,
          message: 'Gagal melakukan booking.',
          isError: true,
        );
      }
    } catch (_) {
      if (!mounted) return;
      CustomToast.show(
        context,
        message: 'Terjadi kesalahan server.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _cancelBookedSlot(CookieRequest request, BookingSlot slot) async {
    if (_cancellingSlotIds.contains(slot.id)) return;

    ConfirmationModal.show(
      context,
      title: 'Batalkan booking?',
      message: 'Slot ${slot.startTime} - ${slot.endTime} akan dibatalkan.',
      confirmText: 'Batalkan',
      cancelText: 'Kembali',
      isDanger: true,
      onConfirm: () async {
        setState(() {
          _cancellingSlotIds.add(slot.id);
        });

        try {
          final res = await request.postJson(
            'http://10.0.2.2:8000/booking/cancel-flutter/',
            jsonEncode({'slot_id': slot.id}),
          );

          if (!mounted) return;

          if (res['status'] == 'success') {
            _selectedSlotIds.remove(slot.id);
            setState(() {});
            CustomToast.show(
              context,
              message: 'Booking dibatalkan.',
            );
          } else {
            CustomToast.show(
              context,
              message: res['message'] ?? 'Gagal membatalkan booking.',
              isError: true,
            );
          }
        } catch (_) {
          if (!mounted) return;
          CustomToast.show(
            context,
            message: 'Terjadi kesalahan server.',
            isError: true,
          );
        } finally {
          if (mounted) {
            setState(() {
              _cancellingSlotIds.remove(slot.id);
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      appBar: AppBar(
        title: const Text('Booking Ticket'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VenueHeaderCard(
                    venueName: widget.venueName,
                    venuePrice: widget.venuePrice,
                    venueAddress: widget.venueAddress,
                    venueType: widget.venueType,
                    venueImageUrl: widget.venueImageUrl,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Choose Your Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF293241),
                    ),
                  ),
                  const SizedBox(height: 12),
                  BookingCalendar(
                    visibleMonth: _visibleMonth,
                    selectedDate: _selectedDate,
                    onSelectDate: _selectDate,
                    onMonthChanged: (month) => setState(() {
                      _visibleMonth = month;
                    }),
                  ),
                  const SizedBox(height: 16),
                  SlotsSection(
                    futureSlots: _fetchSlots(request),
                    selectedSlotIds: _selectedSlotIds,
                    onToggle: _toggleSlot,
                    isSlotPast: _isSlotPast,
                    onCancelBookedSlot: (slot) => _cancelBookedSlot(request, slot),
                    cancellingSlotIds: _cancellingSlotIds,
                  ),
                  const SizedBox(height: 24),
                  SummaryBox(
                    pricePerSlot: widget.venuePrice,
                    bookingCount: _selectedSlotIds.length,
                    totalPrice: _totalPrice,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: CustomButton(
                  text: 'Book Now',
                  isFullWidth: true,
                  isLoading: _isSubmitting,
                  color: Colors.orange,
                  onPressed: request.loggedIn && _selectedSlotIds.isNotEmpty && !_isSubmitting
                      ? () => _submitBooking(request)
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
