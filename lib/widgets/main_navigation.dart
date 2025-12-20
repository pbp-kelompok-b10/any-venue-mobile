import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:any_venue/main.dart';

import 'package:any_venue/screens/home_page.dart';
import 'package:any_venue/account/screens/profile_page.dart';
import 'package:any_venue/venue/screens/my_venue_page.dart';
import 'package:any_venue/review/screens/my_review_page.dart';

import 'package:any_venue/widgets/create_modal.dart';

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
  final GlobalKey<MyVenuePageState> _myVenueKey = GlobalKey<MyVenuePageState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final String role = request.jsonData['role'] ?? 'USER';
    final bool isOwner = role == 'OWNER';

    // Generate Nav Items
    final List<BottomNavigationBarItem> navItems = _getNavItems(isOwner);

    return Scaffold(
      extendBody: true,
      
      // Ambil Screen berdasarkan index yang sudah di-handle logikanya
      body: _getScreenForIndex(_selectedIndex, isOwner),

      floatingActionButton: isOwner ? _buildGradientFab(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: _buildModernBottomNavBar(navItems, isOwner),
    );
  }


  // --- LOGIC MAP SCREEN ---
  Widget _getScreenForIndex(int index, bool isOwner) {
    // List Screen Asli
    final List<Widget> ownerScreens = [
      const HomePage(),
      MyVenuePage(key: _myVenueKey),
      const Center(child: Text("My Events")),
      const ProfilePage(),
    ];

    final List<Widget> userScreens = [
      const HomePage(),
      const Center(child: Text("My Bookings")),
      const Center(child: Text("My Events")),
      const MyReviewPage(),
      const ProfilePage(),
    ];
    
    if (isOwner) {
      // Mapping Index Navbar -> Index Screen
      // Nav: [0:Home, 1:Venue, 2:DUMMY, 3:Event, 4:Profile]
      if (index == 0) return ownerScreens[0];
      if (index == 1) return ownerScreens[1];
      if (index == 3) return ownerScreens[2]; // Lompat dummy
      if (index == 4) return ownerScreens[3];
      return ownerScreens[0]; // Default fallback
    } else {
      if (index >= userScreens.length) return userScreens[0];
      return userScreens[index];
    }
  }

  // --- GRADIENT FAB ---
  Widget _buildGradientFab(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.only(top: 30), // Margin top diperbesar agar FAB agak turun/pas di tengah curve
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [MyApp.gumetalSlate, MyApp.darkSlate],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: MyApp.gumetalSlate.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final created = await CreateActionModal.show(context);
            if (created == true) {
              _myVenueKey.currentState?.refresh();
            }
          },
          customBorder: const CircleBorder(),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  // --- BOTTOM NAV BAR ---
  Widget _buildModernBottomNavBar(List<BottomNavigationBarItem> items, bool isOwner) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        
        // Theme Wrapper untuk Hapus Shadow Abu
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            currentIndex: _selectedIndex,
            
            onTap: (index) {
              if (isOwner && index == 2) return; 
              
              setState(() => _selectedIndex = index);
            },

            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, height: 1.5),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11, height: 1.5),
            selectedItemColor: MyApp.gumetalSlate,
            unselectedItemColor: Colors.grey.shade400,
            showUnselectedLabels: true,
            items: items,
          ),
        ),
      ),
    );
  }

  // --- HELPER ITEMS ---
  BottomNavigationBarItem _buildNavItem(IconData iconOutline, IconData iconFilled, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Icon(iconOutline, size: 24),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Icon(iconFilled, size: 28),
      ),
      label: label,
    );
  }

  // --- ITEM KOSONG (DUMMY) ---
  BottomNavigationBarItem _buildDummyItem() {
    return const BottomNavigationBarItem(
      icon: SizedBox.shrink(), // Icon tidak terlihat
      label: '', // Label kosong
    );
  }

  List<BottomNavigationBarItem> _getNavItems(bool isOwner) {
    if (isOwner) {
      return [
        _buildNavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
        _buildNavItem(Icons.stadium_outlined, Icons.stadium_rounded, 'Venue'),
        
        // Insert Dummy Item di tengah untuk memberi jarak FAB
        _buildDummyItem(), 
        
        _buildNavItem(Icons.confirmation_number_outlined, Icons.confirmation_number_rounded, 'Event'),
        _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
      ];
    }
    
    // User biasa (Tanpa FAB, urutan normal 5 item)
    return [
      _buildNavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
      _buildNavItem(Icons.calendar_today_outlined, Icons.calendar_month_rounded, 'Booking'),
      _buildNavItem(Icons.confirmation_number_outlined, Icons.confirmation_number_rounded, 'Event'),
      _buildNavItem(Icons.star_outline_rounded, Icons.star_rounded, 'Review'),
      _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
    ];
  }
}