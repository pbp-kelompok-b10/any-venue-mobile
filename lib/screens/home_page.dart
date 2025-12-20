import 'package:any_venue/event/models/event.dart';
import 'package:any_venue/event/screens/event_page.dart';
import 'package:any_venue/event/screens/event_page_detail.dart';
import 'package:any_venue/event/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:any_venue/main.dart';
import 'package:any_venue/screens/search_page.dart';
import 'package:any_venue/widgets/components/search_bar.dart';

import 'package:any_venue/venue/screens/venue_page.dart';
import 'package:any_venue/venue/models/venue.dart';
import 'package:any_venue/venue/widgets/venue_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Fetch API Venues
  Future<List<Venue>> _fetchVenues(CookieRequest request) async {
    final response = await request.get(
      'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/venue/api/venues-flutter/',
    );
    final List<Venue> list = [];
    for (var d in response) {
      if (d != null) list.add(Venue.fromJson(d));
    }
    return list;
  }

  // Fetch API Events with Sorting Logic
  Future<List<EventEntry>> _fetchEvents(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/event/json/');
    final List<EventEntry> allEvents = [];
    for (var d in response) {
      if (d != null) allEvents.add(EventEntry.fromJson(d));
    }

    final now = DateTime.now();
    
    // Separate Active and Past events
    List<EventEntry> activeEvents = allEvents.where((e) => e.date.isAfter(now) || DateUtils.isSameDay(e.date, now)).toList();
    List<EventEntry> pastEvents = allEvents.where((e) => e.date.isBefore(now) && !DateUtils.isSameDay(e.date, now)).toList();

    // Sort Active Events by closest date
    activeEvents.sort((a, b) => a.date.compareTo(b.date));
    
    // Combine: Active first (sorted), then Past
    return [...activeEvents, ...pastEvents];
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final String username = request.jsonData['username'] ?? 'Guest';

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        centerTitle: true,

        title: CustomSearchBar(
          hintText: "Cari venue atau event...",
          readOnly: true, 
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            );
          },
        ),

        actions: const [SizedBox(width: 24)],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            // HEADER AREA
            SizedBox(
              height: 340, // Tinggi container header
              width: double.infinity,
              child: Stack(
                children: [
                  // 1. Background Image
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/header.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: MyApp.darkSlate),
                    ),
                  ),

                  // 2. Gradient Fade
                  Positioned(
                    bottom: -1,
                    left: 0,
                    right: 0,
                    height: 200,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.8),
                            Colors.white,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // 3. Welcome Text (FIXED: Pakai Positioned, bukan Column + Spacer)
                  Positioned(
                    bottom: 20,
                    right: 24,
                    left: 24, // Agar tidak overflow jika teks panjang
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Welcome,",
                          style: GoogleFonts.nunitoSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: MyApp.gumetalSlate.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          "$username!",
                          textAlign: TextAlign.right,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: MyApp.gumetalSlate,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // VENUES
            _buildSectionHeader("Venues", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VenuePage()),
              );
            }),
            const SizedBox(height: 8),

            FutureBuilder(
              future: _fetchVenues(request),
              builder: (context, AsyncSnapshot<List<Venue>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 310,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text("Belum ada venue."),
                  );
                } else {
                  return VenueList(
                    venues: snapshot.data!,
                    listType: VenueListType.horizontalFeat,
                    onRefresh: () {
                      setState(() {});
                    },
                  );
                }
              },
            ),

            const SizedBox(height: 180),

            // EVENTS
            _buildSectionHeader("Upcoming Events", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventPage()),
              );
            }),
            const SizedBox(height: 16),
            
            FutureBuilder(
              future: _fetchEvents(request),
              builder: (context, AsyncSnapshot<List<EventEntry>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 150,
                    child: Center(child: CircularProgressIndicator())
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Text("Belum ada event."),
                  );
                } else {
                  final events = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    // Show top 3 based on the new sorting rules
                    itemCount: events.length > 3 ? 3 : events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EventCard(
                          event: event,
                          onArrowTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EventDetailPage(event: event)),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk section header
  Widget _buildSectionHeader(String title, VoidCallback onTapSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.nunitoSans(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: MyApp.gumetalSlate,
            ),
          ),

          MouseRegion(
            cursor: SystemMouseCursors.click, 
            child: GestureDetector(
              onTap: onTapSeeAll,
              child: Text(
                "See all",
                style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  color: MyApp.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
