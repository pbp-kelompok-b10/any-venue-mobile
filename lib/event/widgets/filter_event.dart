import 'package:flutter/material.dart';

class FilterEventButton extends StatelessWidget {
  final VoidCallback? onTap;

  const FilterEventButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.filter_list,
              color: Color(0xFF293241),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Filters',
              style: TextStyle(
                color: Color(0xFF293241),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF293241),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
