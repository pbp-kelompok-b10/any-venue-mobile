import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/venue/screens/venue_form.dart';

class CreateActionModal extends StatelessWidget {
  const CreateActionModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreateActionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create",
            style: GoogleFonts.nunitoSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: MyApp.gumetalSlate,
            ),
          ),
          const SizedBox(height: 20),
          
          // PILIHAN 1: ADD VENUE
          _OptionItem(
            icon: Icons.stadium_rounded,
            color: MyApp.darkSlate,
            iconColor: Colors.white,
            label: "New Venue",
            subLabel: "Add a sport field",
            onTap: () {
              Navigator.pop(context); // Tutup modal dulu
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VenueFormPage()),
              );
            },
          ),
          
          const SizedBox(height: 16),

          // PILIHAN 2: ADD EVENT
          _OptionItem(
            icon: Icons.emoji_events_rounded,
            color: MyApp.orange,
            iconColor: Colors.white,
            label: "New Event",
            subLabel: "Host a tournament or match",
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigasi ke Event Form
            },
          ),
        ],
      ),
    );
  }
}

// Private widget, hanya dipakai di file ini
class _OptionItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final String label;
  final String subLabel;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.label,
    required this.subLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MyApp.gumetalSlate,
                  ),
                ),
                Text(
                  subLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_right_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}