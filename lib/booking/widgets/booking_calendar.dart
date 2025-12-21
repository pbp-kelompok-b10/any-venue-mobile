import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:any_venue/main.dart'; 

class BookingCalendar extends StatelessWidget {
  const BookingCalendar({
    super.key,
    required this.visibleMonth,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onMonthChanged,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMM yyyy').format(visibleMonth);
    final days = _generateCalendarDays(visibleMonth);
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Bulan & Navigasi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => onMonthChanged(
                  DateTime(visibleMonth.year, visibleMonth.month - 1),
                ),
                icon: const Icon(Icons.chevron_left),
                color: MyApp.gumetalSlate,
              ),
              Text(
                monthLabel,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: MyApp.gumetalSlate,
                ),
              ),
              IconButton(
                onPressed: () => onMonthChanged(
                  DateTime(visibleMonth.year, visibleMonth.month + 1),
                ),
                icon: const Icon(Icons.chevron_right),
                color: MyApp.gumetalSlate,
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: const [
              Expanded(child: Center(child: _DayHeader(text: 'Mo'))),
              Expanded(child: Center(child: _DayHeader(text: 'Tu'))),
              Expanded(child: Center(child: _DayHeader(text: 'We'))),
              Expanded(child: Center(child: _DayHeader(text: 'Th'))),
              Expanded(child: Center(child: _DayHeader(text: 'Fr'))),
              Expanded(child: Center(child: _DayHeader(text: 'Sa'))),
              Expanded(child: Center(child: _DayHeader(text: 'Su'))),
            ],
          ),
          // -------------------------
          
          const SizedBox(height: 8),
          
          // Grid Tanggal
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
              final isCurrentMonth = day.month == visibleMonth.month;
              final isPast = day.isBefore(DateTime(today.year, today.month, today.day));
              final isSelected = DateUtils.isSameDay(day, selectedDate);

              Color bg = Colors.white;
              Color text = MyApp.gumetalSlate; 

              if (!isCurrentMonth) {
                text = Colors.grey.shade400; 
              }
              if (isSelected) {
                bg = MyApp.darkSlate;
                text = Colors.white;
              }
              if (isPast) {
                text = Colors.grey.shade300; 
              }

              return GestureDetector(
                onTap: isPast ? null : () => onSelectDate(day),
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? MyApp.darkSlate : Colors.grey.shade200,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: GoogleFonts.nunitoSans(
                      fontWeight: FontWeight.w600,
                      color: text,
                    ),
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
    final startOffset = (first.weekday + 6) % 7;
    final days = <DateTime>[];

    for (int i = startOffset; i > 0; i--) {
      days.add(first.subtract(Duration(days: i)));
    }

    for (int d = 1; d <= last.day; d++) {
      days.add(DateTime(month.year, month.month, d));
    }

    while (days.length % 7 != 0) {
      final nextDay = days.last.add(const Duration(days: 1));
      days.add(nextDay);
    }

    return days;
  }
}

class _DayHeader extends StatelessWidget {
  final String text;
  const _DayHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunitoSans(
        color: MyApp.orange, 
        fontWeight: FontWeight.w700,
      ),
    );
  }
}