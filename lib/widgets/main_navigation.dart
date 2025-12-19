import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:any_venue/main.dart'; 

import 'package:any_venue/screens/home_page.dart';
import 'package:any_venue/venue/screens/venue_form.dart';

import 'package:any_venue/account/models/profile.dart';
import 'package:any_venue/account/screens/profile_page.dart';

class MainNavigation extends StatefulWidget {

  final int initialIndex;

  const MainNavigation({
    super.key, 
    this.initialIndex = 0, 
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    // 3. Set index awal sesuai parameter yang dikirim
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    final String role = request.jsonData['role'] ?? 'USER';
    final bool isOwner = role == 'OWNER';

    // LIST HALAMAN
    final List<Widget> screens;
    
    if (isOwner) {
      screens = [
        const HomePage(),
        const Center(child: Text("My Venues")), 
        const Center(child: Text("My Events")), 
        const ProfilePage(),     
      ];
    } else {
      screens = [
        const HomePage(),
        const Center(child: Text("My Bookings")), 
        const Center(child: Text("My Events")), 
        const Center(child: Text("My Reviews")),  
        const ProfilePage(),      
      ];
    }

    // LIST ITEM NAVBAR
    final List<BottomNavigationBarItem> items;

    if (isOwner) {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.stadium_outlined), activeIcon: Icon(Icons.stadium_rounded), label: 'Venue'),
        BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), activeIcon: Icon(Icons.confirmation_number), label: 'Event'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
      ];
    } else {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_month), label: 'Booking'),
        BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), activeIcon: Icon(Icons.confirmation_number), label: 'Event'),
        BottomNavigationBarItem(icon: Icon(Icons.star_outline_rounded), activeIcon: Icon(Icons.star_rounded), label: 'Review'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
      ];
    }

    if (_selectedIndex >= screens.length) {
      _selectedIndex = screens.length - 1; 
    }

    return Scaffold(
      body: screens[_selectedIndex],
      
      // ===============================================
      // 1. TOMBOL TAMBAH (FAB) KHUSUS OWNER
      // ===============================================
      floatingActionButton: isOwner 
        ? FloatingActionButton(
            onPressed: () => _showCreateModal(context),
            backgroundColor: MyApp.gumetalSlate, // Warna Orange biar mencolok
            elevation: 5,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ) 
        : null,
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ===============================================
      // 2. BOTTOM NAVIGATION BAR
      // ===============================================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: MyApp.gumetalSlate.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, 
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: MyApp.gumetalSlate,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10), // Font diperkecil sedikit agar muat 5
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
          items: items,
        ),
      ),
    );
  }

  // ===============================================
  // 3. MODAL POPUP (Venue / Event)
  // ===============================================
  void _showCreateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 250, // Tinggi modal
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
              _buildOptionItem(
                icon: Icons.stadium_rounded,
                color: MyApp.gumetalSlate,
                iconColor: Colors.white,
                label: "New Venue",
                subLabel: "Add a sport field",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const VenueFormPage())
                  );
                },
              ),
              
              const SizedBox(height: 16),

              // PILIHAN 2: ADD EVENT
              _buildOptionItem(
                icon: Icons.emoji_events_rounded,
                color: MyApp.orange,
                iconColor: Colors.white,
                label: "New Event",
                subLabel: "Host a tournament or match",
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Pindah ke Form Event (Create Mode)
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget Helper untuk Item Modal
  Widget _buildOptionItem({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String label,
    required String subLabel,
    required VoidCallback onTap,
  }) {
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