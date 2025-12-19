import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:any_venue/widgets/components/button.dart';

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
  bool _isSubmitting = false;

  String get _formattedDateLabel {
    final formatter = DateFormat('d MMM yyyy');
    return formatter.format(_selectedDate);
  }

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Booking berhasil! Total: IDR ${_totalPrice.toStringAsFixed(0)}',
            ),
          ),
        );
        setState(() {
          _selectedSlotIds.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal melakukan booking.')),
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
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
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
                  _VenueHeaderCard(widget: widget),
                  const SizedBox(height: 24),
                  const Text(
                    'Choose Your Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCalendar(),
                  const SizedBox(height: 16),
                  _buildSlotsSection(request),
                  const SizedBox(height: 24),
                  _buildSummaryBox(),
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

  Widget _buildCalendar() {
    final monthLabel = DateFormat('MMM yyyy').format(_visibleMonth);
    final days = _generateCalendarDays(_visibleMonth);
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                monthLabel,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Mo'),
              Text('Tu'),
              Text('We'),
              Text('Th'),
              Text('Fr'),
              Text('Sa'),
              Text('Su'),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isCurrentMonth = day.month == _visibleMonth.month;
              final isPast = day.isBefore(DateTime(today.year, today.month, today.day));
              final isSelected = DateUtils.isSameDay(day, _selectedDate);

              Color bg = Colors.white;
              Color text = Colors.black87;

              if (!isCurrentMonth) {
                text = Colors.grey.shade400;
              }
              if (isSelected) {
                bg = Colors.orange.shade100;
                text = Colors.orange.shade800;
              }
              if (isPast) {
                text = Colors.grey.shade300;
              }

              return GestureDetector(
                onTap: isPast ? null : () => _selectDate(day),
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? Colors.orange : Colors.grey.shade200),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(fontWeight: FontWeight.w600, color: text),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<DateTime> _generateCalendarDays(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    // Shift so Monday=0, Sunday=6
    final startOffset = (first.weekday + 6) % 7;
    final days = <DateTime>[];

    // Fill leading blanks with previous month days (still selectable logic handles)
    for (int i = startOffset; i > 0; i--) {
      days.add(first.subtract(Duration(days: i)));
    }

    for (int d = 1; d <= last.day; d++) {
      days.add(DateTime(month.year, month.month, d));
    }

    // Ensure full weeks (42 cells)
    while (days.length % 7 != 0) {
      final nextDay = days.last.add(const Duration(days: 1));
      days.add(nextDay);
    }

    return days;
  }

  Widget _buildSlotsSection(CookieRequest request) {
    return FutureBuilder<List<BookingSlot>>(
      future: _fetchSlots(request),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Gagal memuat jadwal.'),
          );
        }

        final slots = (snapshot.data ?? []).where((s) => !_isSlotPast(s)).toList();
        if (slots.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Tidak ada jadwal tersedia untuk tanggal ini.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) {
            final isSelected = _selectedSlotIds.contains(slot.id);

            Color bg;
            Color border;
            Color text;

            if (slot.isBooked) {
              bg = Colors.grey.shade200;
              border = Colors.grey.shade300;
              text = Colors.grey;
            } else if (slot.isBookedByUser) {
              bg = Colors.blue.shade50;
              border = Colors.blue;
              text = Colors.blue.shade900;
            } else if (isSelected) {
              bg = Colors.orange.shade50;
              border = Colors.orange;
              text = Colors.orange.shade800;
            } else {
              bg = Colors.white;
              border = Colors.grey.shade300;
              text = Colors.black87;
            }

            return GestureDetector(
              onTap: () => _toggleSlot(slot),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: border),
                  boxShadow: bg == Colors.white
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  '${slot.startTime} - ${slot.endTime}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: text,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSummaryBox() {
    final priceFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'IDR ',
      decimalDigits: 0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow('Price', priceFormatter.format(widget.venuePrice)),
          const SizedBox(height: 8),
          _buildSummaryRow('Number of bookings', _selectedSlotIds.length.toString()),
          const Divider(height: 24),
          _buildSummaryRow('Total', priceFormatter.format(_totalPrice), isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _VenueHeaderCard extends StatelessWidget {
  const _VenueHeaderCard({required this.widget});

  final BookingScreen widget;

  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'IDR ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
              image: widget.venueImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(widget.venueImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.venueImageUrl == null
                ? const Icon(Icons.image_not_supported, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.venueName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.sports_tennis, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      widget.venueType,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.venueAddress,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${priceFormatter.format(widget.venuePrice)}/sesi',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
