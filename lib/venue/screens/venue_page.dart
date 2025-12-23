import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/widgets/components/search_bar.dart';
import 'package:any_venue/widgets/components/app_bar.dart';
import 'package:any_venue/venue/models/venue_filter.dart';
import 'package:any_venue/venue/widgets/venue_filter_modal.dart';
import 'package:any_venue/venue/models/venue.dart';
import 'package:any_venue/venue/widgets/venue_list.dart';

class VenuePage extends StatefulWidget {
  final String? initialCategory;

  const VenuePage({super.key, this.initialCategory});

  @override
  State<VenuePage> createState() => _VenuePageState();
}

class _VenuePageState extends State<VenuePage> {
  // 1. Search Logic
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // 2. Filter Logic
  late VenueFilter _filter;

  // 3. Data
  Future<List<Venue>>? _venueFuture;
  List<Venue> _allVenues = [];

  @override
  void initState() {
    super.initState();
    // Inisialisasi Filter
    _filter = VenueFilter(category: widget.initialCategory);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshData() {
    final request = context.read<CookieRequest>();
    setState(() {
      _venueFuture = _fetchAllVenues(request);
    });
  }

  Future<List<Venue>> _fetchAllVenues(CookieRequest request) async {
    final response = await request.get(
      'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/venue/api/venues-flutter/',
    );
    List<Venue> list = [];
    for (var d in response) {
      if (d != null) list.add(Venue.fromJson(d));
    }
    _allVenues = list;
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Venues"),

      body: Column(
        children: [
          // Header: Search Bar & Filter Icon
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              children: [
                Expanded(
                  child: CustomSearchBar(
                    controller: _searchController,
                    hintText: "Search for venues...",
                    readOnly: false,
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 12),

                // Tombol Filter memanggil Modal
                InkWell(
                  onTap: _openFilterModal, // Panggil fungsi buka modal
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: MyApp.gumetalSlate,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List Venue
          Expanded(
            child: FutureBuilder<List<Venue>>(
              future: _venueFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: MyApp.darkSlate));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No venue yet."));
                }

                // --- LOGIKA FILTER ---
                final filteredVenues = snapshot.data!.where((venue) {
                  return _filter.matches(venue, _searchQuery);
                }).toList();

                if (filteredVenues.isEmpty) {
                  return _buildEmptyState();
                }

                return VenueList(
                  venues: filteredVenues,
                  listType: VenueListType.verticalSmall,
                  scrollable: true,
                  onRefresh: _refreshData,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Logic Membuka Modal
  void _openFilterModal() {
    // List untuk dropdown di modal
    final cities = _allVenues.map((v) => v.city.name).toSet().toList();
    final categories = _allVenues.map((v) => v.category.name).toSet().toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Panggil Widget Modal
        return VenueFilterModal(
          currentFilter: _filter,
          cities: cities,
          categories: categories,
          onApply: (newFilter) {
            setState(() {
              _filter =
                  newFilter; // Update filter utama dengan hasil dari modal
            });
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "No Matching venues found :(",
            style: TextStyle(color: MyApp.orange),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = "";
                _searchController.clear();
                _filter.reset();
              });
            },
            child: const Text("Reset Filter"),
          ),
        ],
      ),
    );
  }
}
