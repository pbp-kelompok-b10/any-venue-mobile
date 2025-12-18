import 'package:any_venue/event/models/event.dart';
import 'package:any_venue/event/screens/event_filter.dart';
import 'package:any_venue/event/screens/event_page_detail.dart';
import 'package:any_venue/event/widgets/event_card.dart';
import 'package:any_venue/event/widgets/filter_event.dart';
import 'package:any_venue/widgets/components/search_bar.dart';
import 'package:flutter/material.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  // Master list of all events with updated data to match filter options
  final List<EventEntry> _allEvents = [
    EventEntry(
        id: 1, name: 'Slam Dunk Festival', description: 'A massive basketball event for all ages. Experience an electrifying performance featuring their greatest hits, mind-blowing visuals, and an atmosphere like no other.',
        date: DateTime(2025, 5, 10), startTime: '09:00', registeredCount: 150,
        venueName: 'Gor Grogol', venueAddress: 'Jakarta Barat', 
        venueCategory: 'Basket', venueType: 'Indoor', 
        owner: 'Budi Santoso', ownerId: 1, thumbnail: 'https://images.pexels.com/photos/1752757/pexels-photo-1752757.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1', isOwner: false
    ),
    EventEntry(
        id: 2, name: 'Sudirman Cup Amateur', description: 'Badminton tournament for amateur players. Show your skills and win the cup!',
        date: DateTime(2025, 3, 15), startTime: '08:00', registeredCount: 80,
        venueName: 'Gor Bulutangkis', venueAddress: 'Depok', 
        venueCategory: 'Badminton', venueType: 'Indoor', 
        owner: 'Susi Susanti', ownerId: 2, thumbnail: 'https://images.pexels.com/photos/3660204/pexels-photo-3660204.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1', isOwner: false
    ),
    EventEntry(
        id: 3, name: 'Mini Soccer Night', description: 'Friendly mini soccer match under the stars.',
        date: DateTime(2025, 6, 20), startTime: '19:00', registeredCount: 22,
        venueName: 'Lapangan Hijau', venueAddress: 'Tangerang Selatan', 
        venueCategory: 'Mini Soccer', venueType: 'Outdoor', 
        owner: 'Andi Wijaya', ownerId: 3, thumbnail: 'https://images.pexels.com/photos/114288/pexels-photo-114288.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1', isOwner: false
    ),
    EventEntry(
        id: 4, name: 'Futsal Corporate League', description: 'Corporate league for companies in Jakarta.',
        date: DateTime(2025, 4, 1), startTime: '10:00', registeredCount: 200,
        venueName: 'Futsal City', venueAddress: 'Jakarta Pusat', 
        venueCategory: 'Futsal', venueType: 'Indoor', 
        owner: 'Rian Firman', ownerId: 4, thumbnail: 'https://images.pexels.com/photos/159491/football-kickoff-soccer-starting-line-159491.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1', isOwner: false
    ),
    EventEntry(
        id: 5, name: 'Tenis Weekend Club', description: 'Join our weekend tennis club for a fun session.',
        date: DateTime(2025, 2, 28), startTime: '07:00', registeredCount: 12,
        venueName: 'Tennis Court Kemang', venueAddress: 'Jakarta Selatan', 
        venueCategory: 'Tenis', venueType: 'Outdoor', 
        owner: 'Maria Sharapova', ownerId: 5, thumbnail: 'https://images.pexels.com/photos/209977/pexels-photo-209977.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1', isOwner: false
    ),
  ];

  late List<EventEntry> _filteredEvents;
  final _searchController = TextEditingController();

  // Current filter states
  List<String> _selectedCities = [];
  List<String> _selectedCategories = [];
  List<String> _selectedTypes = [];
  String? _selectedDateOrder;

  @override
  void initState() {
    super.initState();
    _filteredEvents = List.from(_allEvents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyAllFilters() {
    setState(() {
      _filteredEvents = _allEvents.where((event) {
        // 1. Search Bar Filter
        bool matchesSearch = event.name.toLowerCase().contains(_searchController.text.toLowerCase());
        
        // 2. City Filter
        bool matchesCity = _selectedCities.isEmpty || _selectedCities.contains(event.venueAddress);
        
        // 3. Category Filter
        bool matchesCategory = _selectedCategories.isEmpty || _selectedCategories.contains(event.venueCategory);
        
        // 4. Type Filter
        bool matchesType = _selectedTypes.isEmpty || _selectedTypes.contains(event.venueType);

        return matchesSearch && matchesCity && matchesCategory && matchesType;
      }).toList();

      // 5. Date Sorting
      if (_selectedDateOrder == 'Closest') {
        _filteredEvents.sort((a, b) => a.date.compareTo(b.date));
      } else if (_selectedDateOrder == 'Fartest') {
        _filteredEvents.sort((a, b) => b.date.compareTo(a.date));
      }
    });
  }

  void _navigateToDetail(EventEntry event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventDetailPage(event: event)),
    );
  }

  Future<void> _navigateToFilter() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EventFilterPage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedCities = List<String>.from(result['cities'] ?? []);
        _selectedCategories = List<String>.from(result['categories'] ?? []);
        _selectedTypes = List<String>.from(result['types'] ?? []);
        _selectedDateOrder = result['date'];
      });
      _applyAllFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFFAFAFA),
            surfaceTintColor: Colors.transparent,
            floating: true,
            pinned: false,
            forceElevated: true,
            elevation: 8,
            shadowColor: const Color(0x0C683BFC),
            title: const Text('Venues',
              style: TextStyle(
                color: Color(0xFF13123A), 
                fontSize: 16, 
                fontWeight: FontWeight.w700
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF13123A)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSearchBar(
                    controller: _searchController,
                    hintText: 'Search Event',
                    onChanged: (_) => _applyAllFilters(),
                  ),
                  const SizedBox(height: 16),
                  FilterEventButton(
                    onTap: _navigateToFilter,
                  ),
                ],
              ), 
            ),
          ),
          
          _filteredEvents.isEmpty 
          ? const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: Center(child: Text("No events found", style: TextStyle(color: Colors.grey))),
              ),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final event = _filteredEvents[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: EventCard(
                      event: event, 
                      onTap: () {},
                      onArrowTap: () => _navigateToDetail(event),
                    ),
                  );
                },
                childCount: _filteredEvents.length,
              ),
            ),
        ],
      ),
    );
  }
}
