import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// --- WIDGETS ---
import 'package:any_venue/widgets/components/app_bar.dart';
import 'package:any_venue/widgets/components/search_bar.dart';
import 'package:any_venue/widgets/confirmation_modal.dart';
import 'package:any_venue/widgets/toast.dart';

// --- MODELS & EVENT WIDGETS ---
import 'package:any_venue/event/models/event.dart'; 
import 'package:any_venue/event/widgets/event_list.dart';
import 'package:any_venue/event/screens/event_form.dart'; 

class MyEventPage extends StatefulWidget {
  const MyEventPage({super.key});

  @override
  State<MyEventPage> createState() => _MyEventPageState();
}

class _MyEventPageState extends State<MyEventPage> {
  // 1. Search & Filter State
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _showPast = false; // false = Upcoming, true = Past

  // 2. Data State
  List<EventEntry> _allMyEvents = []; 
  List<EventEntry> _displayedEvents = []; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllEvents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- API Fetch Logic ---
  Future<void> _fetchAllEvents() async {
    final request = context.read<CookieRequest>();
    setState(() => _isLoading = true);

    try {
      final response = await request.get('https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/event/json/');
      
      List<EventEntry> list = [];
      for (var d in response) {
        if (d != null) {
          EventEntry e = EventEntry.fromJson(d);
          // FILTER: Hanya ambil event jika user adalah owner
          if (e.isOwner) {
            list.add(e);
          }
        }
      }

      if (mounted) {
        setState(() {
          _allMyEvents = list;
          _isLoading = false;
        });
        _applyFilters(); 
      }
    } catch (e) {
      debugPrint("Error fetching events: $e");
      if (mounted) {
        setState(() {
          _allMyEvents = [];
          _displayedEvents = [];
          _isLoading = false;
        });
      }
    }
  }

  // --- Logic Filtering (Search + Time) ---
  void _applyFilters() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    setState(() {
      _displayedEvents = _allMyEvents.where((event) {
        // 1. Filter Waktu (Menggunakan event.date dari model)
        final eventDate = event.date; 
        
        bool isTimeMatch;
        if (_showPast) {
          // Past: Sebelum hari ini
          isTimeMatch = eventDate.isBefore(today);
        } else {
          // Upcoming: Hari ini atau setelahnya
          isTimeMatch = eventDate.isAtSameMomentAs(today) || eventDate.isAfter(today);
        }

        // 2. Filter Search (Menggunakan event.name dari model)
        bool isSearchMatch = true;
        if (_searchQuery.isNotEmpty) {
          isSearchMatch = event.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }

        return isTimeMatch && isSearchMatch;
      }).toList();

      // 3. Sorting
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

  // --- Delete Logic ---
  Future<void> _handleDelete(EventEntry event) async {
    final request = context.read<CookieRequest>();
    
    // Menggunakan event.id sesuai model
    final int idToDelete = event.id; 

    ConfirmationModal.show(
      context,
      title: "Delete Event",
      // Menggunakan event.name sesuai model
      message: "Are you sure to delete '${event.name}'?",
      isDanger: true,
      onConfirm: () async {
        try {
          final response = await request.post(
            'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/event/delete-flutter/$idToDelete/',
            {},
          );
          if (context.mounted && response['status'] == 'success') {
            CustomToast.show(context, message: "Event deleted", isError: false);
            _fetchAllEvents();
          } else {
             if(context.mounted) CustomToast.show(context, message: "Failed", isError: true);
          }
        } catch (_) {}
      },
    );
  }

  // --- Edit Logic ---
  Future<void> _handleEdit(EventEntry event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventFormPage(
        event: event // Mengoper object event ke form
      )),
    );
    if (result == true) _fetchAllEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // App Bar
      appBar: const CustomAppBar(
        title: "My Events",
        showBackButton: false, // Menu utama navbar
      ),

      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            color: Colors.white,
            child: CustomSearchBar(
              controller: _searchController,
              hintText: "Search your event...",
              readOnly: false,
              onChanged: _runSearch,
            ),
          ),

          // Custom Tabs (Upcoming / Past)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: _buildCustomTabs(),
          ),

          // Event List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayedEvents.isEmpty
                    ? _buildEmptyState()
                    : EventList(
                        events: _displayedEvents,
                        listType: EventListType.verticalLarge,
                        scrollable: true,
                        onRefresh: _fetchAllEvents,
                        onEdit: _handleEdit,
                        onDelete: _handleDelete,
                      ),
          ),
        ],
      ),
    );
  }

  // --- Widget Helpers ---

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? "No events found for '$_searchQuery'"
                : _showPast 
                    ? "No past events" 
                    : "No upcoming events",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Tab Filter Logic
  Widget _buildCustomTabs() {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _showPast = false;
                  _applyFilters();
                });
              },
              child: _buildTabButtonContent(
                label: 'Upcoming Events',
                isActive: !_showPast, 
              ),
            ),
          ),
          const SizedBox(width: 8), 
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _showPast = true;
                  _applyFilters();
                });
              },
              child: _buildTabButtonContent(
                label: 'Past Events',
                isActive: _showPast, 
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab Styling Helper
  Widget _buildTabButtonContent({required String label, required bool isActive}) {
    if (isActive) {
      // Style Active (Gradient)
      return Container(
        height: 44, 
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(1.00, 0.50),
            end: Alignment(0.00, 0.50),
            colors: [Color(0xFF315672), Color(0xFF293241)],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 18,
              top: 28, 
              child: Opacity(
                opacity: 0.40,
                child: Container(
                  width: 140,
                  height: 30,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF293241),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Nunito Sans',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Style Inactive (Outline)
      return Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFF13123A)),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF13123A),
              fontSize: 14,
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
        ),
      );
    }
  }
}