import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryBox extends StatelessWidget {
  const SummaryBox({
    super.key,
    required this.pricePerSlot,
    required this.bookingCount,
    required this.totalPrice,
  });

  final int pricePerSlot;
  final int bookingCount;
  final int totalPrice;

  @override
  Widget build(BuildContext context) {
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow('Price', priceFormatter.format(pricePerSlot)),
          const SizedBox(height: 8),
          _buildSummaryRow('Number of bookings', bookingCount.toString()),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFCBD5E1)),
          ),
          _buildSummaryRow('Total', priceFormatter.format(totalPrice), isBold: true),
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
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}
