import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// --- MAIN & THEME ---
import 'package:any_venue/main.dart'; 

// --- WIDGETS ---
import 'package:any_venue/widgets/components/app_bar.dart';
import 'package:any_venue/widgets/components/search_bar.dart';
import 'package:any_venue/widgets/components/custom_button.dart'; 
import 'package:any_venue/widgets/confirmation_modal.dart';
import 'package:any_venue/widgets/toast.dart';

// --- MODELS & EVENT WIDGETS ---
import 'package:any_venue/event/models/event.dart'; 
import 'package:any_venue/event/widgets/event_list.dart';

// PASTIKAN IMPORT INI BENAR SESUAI FOLDER PROJECT KAMU
import 'package:any_venue/event/screens/event_form_page.dart'; 

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  // 1. Search & Filter State
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _showPast = false; 

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
      // GANTI URL INI SESUAI ENDPOINT KAMU
      final response = await request.get('https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/event/json/');
      
      List<EventEntry> list = [];
      for (var d in response) {
        if (d != null) {
          EventEntry e = EventEntry.fromJson(d);
          if (e.isOwner) { // Filter hanya event milik user
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

  // --- Logic Filtering ---
  void _applyFilters() {
    final now = DateTime.now();

    setState(() {
      _displayedEvents = _allMyEvents.where((event) {
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

  Future<void> _handleDelete(EventEntry event) async {
    final request = context.read<CookieRequest>();
    final int idToDelete = event.id; 

    ConfirmationModal.show(
      context,
      title: "Delete Event",
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
             if(context.mounted) CustomToast.show(context, message: "Failed to delete", isError: true);
          }
        } catch (_) {}
      },
    );
  }

  Future<void> _handleEdit(EventEntry event) async {
    // Navigasi ke Form Edit dan tunggu hasilnya
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventFormPage(
        event: event // Kirim data event untuk diedit
      )),
    );
    
    // Jika result == true (berhasil diedit), refresh list
    if (result == true) {
      _fetchAllEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: "My Events",
        showBackButton: false, 
      ),
      
      // ============================================================
      // INI YANG PALING PENTING: TOMBOL CREATE (+)
      // ============================================================
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyApp.gumetalSlate, 
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // 1. Pindah ke halaman form pembuatan event
          // 2. Gunakan 'await' untuk menunggu user selesai membuat event
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EventFormPage(), // Tidak bawa parameter event karena BARU
            ),
          );

          // 3. Jika user berhasil save (result == true), refresh data otomatis!
          if (result == true) {
            _fetchAllEvents();
          }
        },
      ),
      // ============================================================

      body: Column(
        children: [
          // 1. Search Bar
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

          // 2. Custom Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: _buildCustomTabs(),
          ),

          // 3. Event List
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

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
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
            text: 'Upcoming Events',
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
            text: 'Past Events',
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