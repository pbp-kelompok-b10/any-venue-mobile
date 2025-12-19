import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:any_venue/main.dart';

// Import Widgets Komponen
import 'package:any_venue/widgets/components/search_bar.dart';
import 'package:any_venue/widgets/components/app_bar.dart';

// Import Model & Widget Venue
import 'package:any_venue/venue/models/venue.dart';
import 'package:any_venue/venue/widgets/venue_list.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  // 1. Controllers
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // 2. State Variables
  String _searchQuery = "";
  List<Venue> _allVenues = []; // Menyimpan semua data dari API
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inisialisasi Tab Controller (Length 2: Venue & Event)
    _tabController = TabController(length: 2, vsync: this);

    // Fetch data venue saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchVenues();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- API FETCHING ---
  Future<void> _fetchVenues() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/venue/api/venues-flutter/',
      );
      
      List<Venue> list = [];
      for (var d in response) {
        if (d != null) list.add(Venue.fromJson(d));
      }

      if (mounted) {
        setState(() {
          _allVenues = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching venues: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- FILTER LOGIC (MULTI-ATTRIBUTE) ---
  List<Venue> _getFilteredVenues() {
    // 1. Jika query kosong, kembalikan list kosong (sesuai request)
    if (_searchQuery.isEmpty) {
      return [];
    }

    // 2. Filter berdasarkan keyword di SEMUA atribut
    return _allVenues.where((venue) {
      final query = _searchQuery.toLowerCase();
      
      // Cek satu per satu atribut
      final matchName = venue.name.toLowerCase().contains(query);
      final matchCity = venue.city.name.toLowerCase().contains(query);
      final matchCategory = venue.category.name.toLowerCase().contains(query);
      final matchAddress = venue.address.toLowerCase().contains(query);
      final matchType = venue.type.toLowerCase().contains(query);

      // Return true jika SALAH SATU atribut cocok
      return matchName || matchCity || matchCategory || matchAddress || matchType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // 1. Custom AppBar
      appBar: const CustomAppBar(title: "Search"),

      body: Column(
        children: [
          // 2. Search Bar Area
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: "Search venues, cities, or events...",
              readOnly: false,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),

          // 3. Tab Bar (Venue / Event)
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: MyApp.darkSlate,
              unselectedLabelColor: Colors.grey,
              indicatorColor: MyApp.darkSlate,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.nunitoSans(fontWeight: FontWeight.w700, fontSize: 16),
              tabs: const [
                Tab(text: "Venues"),
                Tab(text: "Events"),
              ],
            ),
          ),

          // 4. Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // --- TAB 1: VENUE LIST ---
                _buildVenueTab(),

                // --- TAB 2: EVENT PLACEHOLDER ---
                _buildEventTabPlaceholder(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueTab() {
    // Kondisi 1: Masih Loading Data Awal
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Kondisi 2: User belum mengetik apa-apa
    if (_searchQuery.isEmpty) {
      return _buildInitialState("Type to search venues...");
    }

    // Ambil hasil filter
    final filteredList = _getFilteredVenues();

    // Kondisi 3: User mengetik, tapi tidak ada hasil
    if (filteredList.isEmpty) {
      return _buildEmptyState("No venues found for '$_searchQuery'");
    }

    // Kondisi 4: Menampilkan Hasil
    return VenueList(
      venues: filteredList,
      listType: VenueListType.verticalSmall,
      scrollable: true,
      onRefresh: _fetchVenues, // Pull to refresh update data
    );
  }

  Widget _buildEventTabPlaceholder() {
    // Placeholder Event Logic (Mirip Venue tapi datanya dummy dulu)
    if (_searchQuery.isEmpty) {
      return _buildInitialState("Type to search upcoming events...");
    }
    
    // Tampilan Placeholder Hasil Search Event
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Event search coming soon!",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          Text(
            "You searched for: \"$_searchQuery\"",
            style: const TextStyle(color: MyApp.orange, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Widget Tampilan Awal (Belum Ngetik)
  Widget _buildInitialState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Widget Tampilan Tidak Ditemukan
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.not_listed_location_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: MyApp.orange, fontSize: 16),
          ),
        ],
      ),
    );
  }
}