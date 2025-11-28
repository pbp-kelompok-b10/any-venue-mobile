import 'package:flutter/material.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/screens/home_page.dart';

class NavigationBar extends StatefulWidget {
  const NavigationBar({super.key});

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  int _selectedIndex = 0; // Index halaman yang sedang aktif (0 = Home)

  // Daftar Halaman yang akan ditampilkan
  // TODO: ganti Center(...) ini dengan halaman asli, misal: const BookingPage()
  final List<Widget> _screens = [
    const HomePage(), // Index 0: Halaman Home yang sudah kamu buat
    const Center(child: Text("Bookings Page")), // Index 1
    const Center(child: Text("Events Page")), // Index 2
    const Center(child: Text("Reviews Page")), // Index 3
    const Center(child: Text("Profile Page")), // Index 4
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      
      // Navigasi Bawah
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
          onTap: _onItemTapped,
          
          // Warna Icon & Teks
          selectedItemColor: MyApp.darkSlate,
          unselectedItemColor: MyApp.gumetalSlate,
          
          // Style Teks
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),

          items: const [
            // 1. HOME
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), // Icon saat mati (garis doang)
              activeIcon: Icon(Icons.home_filled), // Icon saat hidup (penuh)
              label: 'Home',
            ),

            // 2. BOOKINGS
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Bookings',
            ),

            // 3. EVENTS (Icon Tiket)
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined),
              activeIcon: Icon(Icons.confirmation_number),
              label: 'Events',
            ),

            // 4. REVIEWS (Icon Bintang/Medali)
            BottomNavigationBarItem(
              icon: Icon(Icons.star_outline_rounded),
              activeIcon: Icon(Icons.star_rounded),
              label: 'Reviews',
            ),

            // 5. PROFILE
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}