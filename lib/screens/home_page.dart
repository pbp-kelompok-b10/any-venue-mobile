import 'package:any_venue/event/models/event.dart';
import 'package:any_venue/event/screens/event_page.dart';
import 'package:any_venue/event/screens/event_page_detail.dart';
import 'package:any_venue/event/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:any_venue/main.dart'; 
import 'package:any_venue/widgets/components/search_bar.dart';

import 'package:any_venue/venue/screens/venue_page.dart'; 
import 'package:any_venue/venue/models/venue.dart';
import 'package:any_venue/venue/widgets/venue_list.dart';
import 'package:any_venue/event/screens/event_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  // Fetch API Venues
  Future<List<Venue>> _fetchVenues(CookieRequest request) async {
    // Note: I'm only updating the Event-related URLs as requested. 
    // If you need the Venue URLs updated later, please let me know.
    final response = await request.get('http://localhost:8000/venue/api/venues-flutter/');
    final List<Venue> list = [];
    for (var d in response) {
      if (d != null) list.add(Venue.fromJson(d));
    }
    return list;
  }

  // Fetch API Events with Sorting Logic - Updated to production URL
  Future<List<EventEntry>> _fetchEvents(CookieRequest request) async {
    final response = await request.get('https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/event/json/');
    final List<EventEntry> allEvents = [];
    for (var d in response) {
      if (d != null) allEvents.add(EventEntry.fromJson(d));
    }

    final now = DateTime.now();
    List<EventEntry> activeEvents = allEvents.where((e) => e.date.isAfter(now) || DateUtils.isSameDay(e.date, now)).toList();
    List<EventEntry> pastEvents = allEvents.where((e) => e.date.isBefore(now) && !DateUtils.isSameDay(e.date, now)).toList();

    activeEvents.sort((a, b) => a.date.compareTo(b.date));
    return [...activeEvents, ...pastEvents];
  }

  void _deleteEvent(EventEntry event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final request = context.read<CookieRequest>();
              Navigator.pop(context);
              
              // Updated to production URL
              final response = await request.post('https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/event/delete-flutter/${event.id}/', {});
              
              if (response['status'] == 'success') {
                setState(() {}); 
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(response['message'] ?? "Error occurred"),
                    backgroundColor: Colors.red,
                  ));
                }
              }
            }, 
            child: const Text('Delete', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
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
            // TODO: Navigate to SearchPage
          },
        ),

        actions: const [
          SizedBox(width: 24),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 340,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/header.jpg', 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: MyApp.darkSlate),
                  ),
                ),

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

                Positioned.fill(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Spacer(),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Welcome,",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: MyApp.gumetalSlate.withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  "$username!",
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: MyApp.gumetalSlate,
                                    height: 1.1,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 60), 
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            _buildSectionHeader("Venues", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VenuePage()),
              );
            }),
            const SizedBox(height: 16),
            
            FutureBuilder(
              future: _fetchVenues(request),
              builder: (context, AsyncSnapshot<List<Venue>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 310, 
                    child: Center(child: CircularProgressIndicator())
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text("Belum ada venue."),
                  );
                } else {
                  return VenueList(
                    venues: snapshot.data!,
                    isLarge: true, 
                    onRefresh: () {
                      setState(() {}); 
                    },
                  );
                }
              },
            ),

            const SizedBox(height: 32),

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
                          onEditTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EventFormPage(event: event)),
                            ).then((value) {
                              if (value == true) setState(() {}); 
                            });
                          },
                          onDeleteTap: () => _deleteEvent(event),
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

  Widget _buildSectionHeader(String title, VoidCallback onTapSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF293241),
            ),
          ),

          MouseRegion(
            cursor: SystemMouseCursors.click, 
            child: GestureDetector(
              onTap: onTapSeeAll,
              child: const Text(
                "See all",
                style: TextStyle(
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
