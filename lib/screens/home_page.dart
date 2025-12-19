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
    final response = await request.get(
      'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/venue/api/venues-flutter/',
    );
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
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        centerTitle: true,

        title: CustomSearchBar(
          hintText: "Cari venue atau event...",
          readOnly: true, // Jadi tombol
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
                  // Venue List Horizontal
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

            const SizedBox(height: 180),

            // EVENTS
            //           _buildSectionHeader("Upcoming Events", () {
            //              // Navigate to All Events Page
            //           }),
            //           const SizedBox(height: 8),

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
            style: GoogleFonts.nunitoSans(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: MyApp.gumetalSlate,
            ),
          ),

          MouseRegion(
            cursor: SystemMouseCursors.click, // Ubah kursor jadi tangan
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
