import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:any_venue/main.dart'; // Akses warna MyApp
import 'package:any_venue/screens/home_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    final String role = request.jsonData['role'] ?? 'User';
    final bool isOwner = role == 'Owner';

    final List<Widget> screens;
    
    if (isOwner) {
      // --- MENU OWNER (5 Item) ---
      screens = [
        const HomePage(),
        const Center(child: Text("My Venues (Owner)")), // TODO: Ganti Page My Venue
        const Center(child: Text("My Events (Owner)")), // TODO: Ganti Page My Event
        const Center(child: Text("Incoming Bookings")), // TODO: Ganti Page Booking Masuk
        const Center(child: Text("Owner Profile")),     // TODO: Ganti Profile Page
      ];
    } else {
      // --- MENU USER BIASA (4 Item) ---
      screens = [
        const HomePage(),
        const Center(child: Text("My Bookings (User)")), // TODO: Ganti Page History Booking
        const Center(child: Text("My Reviews (User)")),  // TODO: Ganti Page History Review
        const Center(child: Text("User Profile")),       // TODO: Ganti Profile Page
      ];
    }

    final List<BottomNavigationBarItem> items;

    if (isOwner) {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.store_mall_directory_outlined), activeIcon: Icon(Icons.store_mall_directory), label: 'My Venue'),
        BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), activeIcon: Icon(Icons.confirmation_number), label: 'My Event'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Booking'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
      ];
    } else {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_month), label: 'My Booking'),
        BottomNavigationBarItem(icon: Icon(Icons.star_outline_rounded), activeIcon: Icon(Icons.star_rounded), label: 'My Review'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
      ];
    }

    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: screens[_selectedIndex],
      
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
          selectedItemColor: MyApp.darkSlate,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
          items: items,
        ),
      ),
    );
  }
}