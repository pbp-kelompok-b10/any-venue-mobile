import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// --- MAIN & THEME ---
import 'package:any_venue/main.dart'; 

// --- WIDGETS ---
import 'package:any_venue/widgets/components/app_bar.dart';
import 'package:any_venue/widgets/components/search_bar.dart';
import 'package:any_venue/widgets/components/button.dart'; 
import 'package:any_venue/widgets/toast.dart'; 

// --- MODELS & EVENT WIDGETS ---
import 'package:any_venue/event/models/event.dart'; 
import 'package:any_venue/event/widgets/event_list.dart';

class MyJoinedEventPage extends StatefulWidget {
  const MyJoinedEventPage({super.key});

  @override
  State<MyJoinedEventPage> createState() => MyJoinedEventPageState(); 
}

class MyJoinedEventPageState extends State<MyJoinedEventPage> {
  // 1. Search & Filter State
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _showPast = false; 

  // 2. Data State
  List<EventEntry> _joinedEvents = []; 
  List<EventEntry> _displayedEvents = []; 
  bool _isLoading = true;

  Future<void> refresh() => _fetchJoinedEvents();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchJoinedEvents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- API Fetch Logic ---
  Future<void> _fetchJoinedEvents() async {
    final request = context.read<CookieRequest>();
    setState(() => _isLoading = true);

    try {
     
      final response = await request.get('https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/event/json/'); 
      
      List<EventEntry> tempJoinedList = [];

      for (var d in response) {
        if (d != null) {
          EventEntry e = EventEntry.fromJson(d);
          
          // Cek ke endpoint check_registration untuk setiap event
          try {
             final regStatus = await request.get('https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/event/${e.id}/check-registration/');
             

             if (regStatus['is_registered'] == true) {
               tempJoinedList.add(e);
             }
          } catch (_) {
             // Skip jika gagal cek status event ini
          }
        }
      }

      if (mounted) {
        setState(() {
          _joinedEvents = tempJoinedList;
          _isLoading = false;
        });
        _applyFilters(); 
      }
    } catch (e) {
      debugPrint("Error fetching joined events: $e");
      if (mounted) {
        setState(() {
          _joinedEvents = [];
          _displayedEvents = [];
          _isLoading = false;
        });
      }
    }
  }

  // --- Logic Filtering ---
  void _applyFilters() {
    final now = DateTime.now();

    setState(() {
      _displayedEvents = _joinedEvents.where((event) {
        final eventDate = event.date; 
        
        bool isTimeMatch;
        if (_showPast) {
          isTimeMatch = eventDate.isBefore(now);
        } else {
          isTimeMatch = eventDate.isAtSameMomentAs(now) || eventDate.isAfter(now);
        }

        bool isSearchMatch = true;
        if (_searchQuery.isNotEmpty) {
          isSearchMatch = event.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }

        return isTimeMatch && isSearchMatch;
      }).toList();

      // Sorting
      if (_showPast) {
        _displayedEvents.sort((a, b) => b.date.compareTo(a.date));
      } else {
        _displayedEvents.sort((a, b) => a.date.compareTo(b.date));
      }
    });
  }

  void _runSearch(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: "Joined Events",
        showBackButton: false, 
      ),
      
      body: Column(
        children: [
          // 1. Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            color: Colors.white,
            child: CustomSearchBar(
              controller: _searchController,
              hintText: "Search joined event...",
              readOnly: false,
              onChanged: _runSearch,
            ),
          ),

          // 2. Custom Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: _buildCustomTabs(),
          ),

          // 3. Event List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: MyApp.darkSlate))
                : _displayedEvents.isEmpty
                    ? _buildEmptyState()
                    : EventList(
                        events: _displayedEvents,
                        listType: EventListType.verticalLarge,
                        scrollable: true,
                        onRefresh: _fetchJoinedEvents,
                        // Edit dimatikan
                        onEdit: null, 
                        // Delete/Cancel dimatikan karena backend tidak support
                        onDelete: null, 
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? "No events found for '$_searchQuery'"
                  : _showPast 
                      ? "No past joined events" 
                      : "You haven't joined any upcoming events",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 80), 
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabs() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Upcoming',
            isOutlined: _showPast, 
            color: MyApp.gumetalSlate, 
            gradientColors: const [MyApp.darkSlate, MyApp.gumetalSlate],
            onPressed: () {
              if (_showPast) {
                setState(() {
                  _showPast = false;
                  _applyFilters();
                });
              }
            },
          ),
        ),
        const SizedBox(width: 8), 
        Expanded(
          child: CustomButton(
            text: 'History', 
            isOutlined: !_showPast, 
            color: MyApp.gumetalSlate,
            gradientColors: const [MyApp.darkSlate, MyApp.gumetalSlate],
            onPressed: () {
              if (!_showPast) {
                setState(() {
                  _showPast = true;
                  _applyFilters();
                });
              }
            },
          ),
        ),
      ],
    );
  }
}