import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:any_venue/main.dart'; 
import 'package:any_venue/widgets/components/search_bar.dart';
import 'package:any_venue/widgets/feature_card.dart';

import 'package:any_venue/venue/screens/venue_page.dart'; 
import 'package:any_venue/venue/models/venue.dart';
import 'package:any_venue/venue/widgets/venue_list.dart';

// import 'package:any_venue/screens/search_page.dart';
// import 'package:any_venue/screens/venue_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  // Fetch API Venues
  Future<List<Venue>> _fetchVenues(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/venue/api/venues-flutter/');
    final List<Venue> list = [];
    for (var d in response) {
      if (d != null) list.add(Venue.fromJson(d));
    }
    return list;
  }

  // Fetch API Events
  Future<List<String>> _fetchEvents() async {
    // TODO: ubah pake api
    await Future.delayed(const Duration(seconds: 1));
    return ["Moshfest 2024", "Java Jazz", "Synchronize Fest"];
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final String username = request.jsonData['username'] ?? 'Guest';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [

            // HEADER AREA
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

                // Gradient Fade
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 180, 
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
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),

                // Search & Welcome Text
                Positioned.fill(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          
                          // Sarch bar
                          CustomSearchBar(
                            hintText: "Cari venue atau event...",
                            readOnly: true, // Keyboard tidak muncul
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => const SearchPage()),
                              // );
                            },
                          ),

                          const Spacer(),

                          // Welcome text
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

            // FEATURE CARDS (OVERLAPPING)
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FeatureCard(
                      icon: Icons.calendar_month_rounded,
                      label: "Booking",
                      onTap: () { /* Navigate to Booking */ },
                    ),
                    FeatureCard(
                      icon: Icons.star_rounded,
                      label: "Reviews",
                      onTap: () { /* Navigate to Reviews */ },
                    ),
                    FeatureCard(
                      icon: Icons.confirmation_number_rounded,
                      label: "Events",
                      onTap: () { /* Navigate to Events */ },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 0), 

            // VENUES
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
                  // Venue List Horizontal
                  return VenueList(
                    venues: snapshot.data!,
                    isLarge: true, 
                  );
                }
              },
            ),

            const SizedBox(height: 32),

            // EVENTS
  //           _buildSectionHeader("Upcoming Events", () {
  //              // Navigate to All Events Page
  //           }),
  //           const SizedBox(height: 16),
            
  //           FutureBuilder(
  //             future: _fetchEvents(),
  //             builder: (context, snapshot) {
  //               if (snapshot.connectionState == ConnectionState.waiting) {
  //                 return const SizedBox(
  //                   height: 310,
  //                   child: Center(child: CircularProgressIndicator())
  //                 );
  //               } else {
  //                 // Event List Horizontal (Manual ListView)
  //                 return SizedBox(
  //                   height: 310,
  //                   child: ListView.separated(
  //                     padding: const EdgeInsets.symmetric(horizontal: 24),
  //                     scrollDirection: Axis.horizontal,
  //                     itemCount: snapshot.data!.length,
  //                     separatorBuilder: (context, index) => const SizedBox(width: 16),
  //                     itemBuilder: (context, index) {
  //                       // return _buildEventCard(context, snapshot.data![index]);
  //                     },
  //                   ),
  //                 );
  //               }
  //             },
  //           ),
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
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF293241),
            ),
          ),
          GestureDetector(
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
        ],
      ),
    );
  }
}