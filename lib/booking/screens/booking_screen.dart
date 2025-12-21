import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Import Main dan Komponen Custom
import 'package:any_venue/main.dart';
import 'package:any_venue/widgets/components/button.dart'; 
import 'package:any_venue/widgets/components/app_bar.dart'; // Pastikan path ini sesuai dengan lokasi file CustomAppBar Anda

import 'package:any_venue/booking/widgets/booking_calendar.dart';
import 'package:any_venue/booking/widgets/slots_section.dart';
import 'package:any_venue/booking/widgets/summary_box.dart';
import 'package:any_venue/booking/widgets/venue_header_card.dart';
import 'package:any_venue/venue/screens/venue_page.dart';
import 'package:any_venue/widgets/confirmation_modal.dart';
import 'package:any_venue/widgets/toast.dart';
import '../models/booking_slot.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({
    super.key,
    required this.venueId,
    required this.venueName,
    required this.venuePrice,
    required this.venueAddress,
    required this.venueType,
    required this.venueCategory,
    this.venueImageUrl,
    this.initialDate,
    this.focusSlotId,
  });

  final int venueId;
  final String venueName;
  final int venuePrice;
  final String venueAddress;
  final String venueType;
  final String venueCategory;
  final String? venueImageUrl;
  final DateTime? initialDate;
  final int? focusSlotId;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  final Set<int> _selectedSlotIds = {};
  final Set<int> _cancellingSlotIds = {};
  bool _isSubmitting = false;
  final Map<String, Future<List<BookingSlot>>> _slotsCache = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _selectedDate = DateTime(widget.initialDate!.year, widget.initialDate!.month, widget.initialDate!.day);
      _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
    }
  }

  Future<List<BookingSlot>> _fetchSlots(CookieRequest request) {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    if (_slotsCache[dateStr] != null) return _slotsCache[dateStr]!;

    final url = 'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/booking/slots/${widget.venueId}/?date=$dateStr';
    final future = request.get(url).then((response) {
      final jsonString = jsonEncode(response);
      final slots = bookingSlotFromJson(jsonString);

      // Auto-select focused slot if this date matches and slot belongs to user
      if (widget.focusSlotId != null) {
        final match = slots.firstWhere(
          (s) => s.id == widget.focusSlotId,
          orElse: () => BookingSlot(
            id: -1,
            startTime: '',
            endTime: '',
            isBooked: false,
            isBookedByUser: false,
            price: 0,
          ),
        );
        if (match.id == widget.focusSlotId && match.isBookedByUser) {
          _selectedSlotIds.add(match.id);
        }
      }

      return slots;
    });

    _slotsCache[dateStr] = future;
    return future;
  }

  int get _totalPrice => _selectedSlotIds.length * widget.venuePrice;

  void _selectDate(DateTime day) {
    final today = DateTime.now();
    if (day.isBefore(DateTime(today.year, today.month, today.day))) return;

    setState(() {
      _selectedDate = day;
      _visibleMonth = DateTime(day.year, day.month);
      _selectedSlotIds.clear();
      final key = DateFormat('yyyy-MM-dd').format(day);
      _slotsCache.remove(key);
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
      final url = 'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/booking/create-flutter/';
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
          message: 'Booking successful!', // English
          subMessage: 'Total paid: IDR ${serverTotal.toString()}', // English
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
          message: 'Booking failed.', // English
          isError: true,
        );
      }
    } catch (_) {
      if (!mounted) return;
      CustomToast.show(
        context,
        message: 'Server error occurred.', // English
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
      title: 'Cancel booking?', // English
      message: 'Slot ${slot.startTime} - ${slot.endTime} will be cancelled.', // English
      confirmText: 'Cancel', // English
      cancelText: 'Back', // English
      isDanger: true,
      onConfirm: () async {
        setState(() {
          _cancellingSlotIds.add(slot.id);
        });

        try {
          final res = await request.postJson(
            'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/booking/cancel-flutter/',
            jsonEncode({'slot_id': slot.id}),
          );

          if (!mounted) return;

          if (res['status'] == 'success') {
            _selectedSlotIds.remove(slot.id);
            setState(() {});
            CustomToast.show(
              context,
              message: 'Booking cancelled.', // English
            );
          } else {
            CustomToast.show(
              context,
              message: res['message'] ?? 'Failed to cancel booking.', // English
              isError: true,
            );
          }
        } catch (_) {
          if (!mounted) return;
          CustomToast.show(
            context,
            message: 'Server error occurred.', // English
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
      // KITA PERTAHANKAN WARNA INI SESUAI PERMINTAAN (KARENA TIDAK ADA DI MAIN.DART)
      backgroundColor: const Color(0xFFF6F7FA), 
      
      // Menggunakan CustomAppBar
      appBar: const CustomAppBar(
        title: 'Booking Ticket',
        showBackButton: true,
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
                    venueCategory: widget.venueCategory,
                    venueImageUrl: widget.venueImageUrl,
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Choose Your Time',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      // Warna ini (0xFF293241) sama dengan gumetalSlate di MyApp, jadi kita pakai variabelnya
                      color: MyApp.gumetalSlate, 
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
          
          // Bagian Tombol Bawah
          SafeArea(
            top: false,
            child: Container(
              // Kita beri background putih di container tombol agar terlihat seperti "sticky footer" yang rapi
              // karena background scaffold berwarna abu-abu (0xFFF6F7FA)
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: CustomButton(
                text: 'Book Now',
                isFullWidth: true,
                color: MyApp.orange, // Menggunakan warna dari MyApp
                isLoading: _isSubmitting, // Loading indicator otomatis dari CustomButton
                onPressed: request.loggedIn && _selectedSlotIds.isNotEmpty && !_isSubmitting
                    ? () => _submitBooking(request)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}