import 'package:flutter/material.dart';

class BookingFilterTabs extends StatelessWidget {
  const BookingFilterTabs({
    super.key,
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

    Widget pill(String label, bool selected, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            height: 46,
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
                fontWeight: FontWeight.w700,
                fontSize: 13,
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
