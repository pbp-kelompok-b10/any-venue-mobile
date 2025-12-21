import 'package:any_venue/event/models/event.dart';
import 'package:any_venue/event/screens/event_filter.dart';
import 'package:any_venue/event/screens/event_form.dart';
import 'package:any_venue/event/screens/event_page_detail.dart';
import 'package:any_venue/event/widgets/event_card.dart';
import 'package:any_venue/event/widgets/event_filter_modal.dart';
import 'package:any_venue/event/widgets/event_list.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/widgets/components/search_bar.dart';
import 'package:any_venue/widgets/confirmation_modal.dart';
import 'package:any_venue/widgets/components/app_bar.dart';
import 'package:any_venue/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  // Master list of events from server
  List<EventEntry> _allEvents = [];
  late List<EventEntry> _filteredEvents;
  bool _isLoading = true;

  final _searchController = TextEditingController();

  List<String> _selectedCategories = [];
  List<String> _selectedTypes = [];
  String? _selectedDateOrder;
  String _selectedOwnership = 'All Event';

  @override
  void initState() {
    super.initState();
    _filteredEvents = [];
    // Fetch data immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEvents();
    });
  }

  Future<void> _fetchEvents() async {
    final request = context.read<CookieRequest>();
    setState(() => _isLoading = true);

    try {
      final response = await request.get('https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/event/json/');
      
      final List<EventEntry> list = [];
      for (var d in response) {
        if (d != null) list.add(EventEntry.fromJson(d));
      }

      setState(() {
        _allEvents = list;
        _isLoading = false;
        _applyAllFilters();
      });
    } catch (e) {
      debugPrint("Error fetching events: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyAllFilters() {
    final now = DateTime.now();
    setState(() {
      List<EventEntry> results = _allEvents.where((event) {
        bool matchesSearch = event.name.toLowerCase().contains(_searchController.text.toLowerCase());
        bool matchesCategory = _selectedCategories.isEmpty || _selectedCategories.contains(event.venueCategory);
        bool matchesType = _selectedTypes.isEmpty || _selectedTypes.contains(event.venueType);

        bool matchesOwnership = true;
        if (_selectedOwnership == 'My Event') {
          matchesOwnership = event.isOwner;
        }

        return matchesSearch && matchesCategory && matchesType && matchesOwnership;
      }).toList();

      List<EventEntry> activeEvents = results.where((e) => e.date.isAfter(now) || DateUtils.isSameDay(e.date, now)).toList();
      List<EventEntry> pastEvents = results.where((e) => e.date.isBefore(now) && !DateUtils.isSameDay(e.date, now)).toList();

      if (_selectedDateOrder == 'Closest') {
        activeEvents.sort((a, b) => a.date.compareTo(b.date));
      } else if (_selectedDateOrder == 'Farthest') {
        activeEvents.sort((a, b) => b.date.compareTo(a.date));
      }
      _filteredEvents = [...activeEvents, ...pastEvents];
    });
  }

  void _navigateToDetail(EventEntry event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventDetailPage(event: event)),
    ).then((value) {
      if (value == true) _fetchEvents(); // Refresh if event was edited or deleted in detail page
    });
  }

  void _navigateToForm({EventEntry? event}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventFormPage(event: event)),
    ).then((value) {
      if (value == true) _fetchEvents(); 
    });
  }

  void _deleteEvent(EventEntry event) {
    ConfirmationModal.show(
      context,
      title: 'Delete Event',
      message: 'Are you sure you want to delete "${event.name}"? This action cannot be undone.',
      confirmText: 'Delete',
      isDanger: true,
      onConfirm: () async {
        final request = context.read<CookieRequest>();
        final response = await request.post('https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/event/delete-flutter/${event.id}/', {});
        
        if (mounted) {
          if (response['status'] == 'success') {
            _fetchEvents(); 
            CustomToast.show(context, message: "Event Deleted", subMessage: response['message'], isError: false);
          } else {
            CustomToast.show(context, message: "Delete Failed", subMessage: response['message'], isError: true);
          }
        }
      },
    );
  }

  Future<void> _navigateToFilter() async {
    final request = context.read<CookieRequest>();
    final String role = request.jsonData['role'] ?? 'USER';
    final bool isOwner = role == 'OWNER';

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return EventFilterModal(
          initialCategories: _selectedCategories,
          initialTypes: _selectedTypes,
          initialDate: _selectedDateOrder,
          initialOwnership: _selectedOwnership,
          isOwner: isOwner,
        );
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedCategories = List<String>.from(result['categories'] ?? []);
        _selectedTypes = List<String>.from(result['types'] ?? []);
        _selectedDateOrder = result['date'];
        _selectedOwnership = result['ownership'] ?? 'All Event';
      });
      _applyAllFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), 
      
      appBar: const CustomAppBar(title: 'Events'), 

      body: Column(
        children: [
          Container(
            color: const Color(0xFFFAFAFA),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              children: [
                Expanded(
                  child: CustomSearchBar(
                    controller: _searchController,
                    hintText: 'Search Event',
                    onChanged: (_) => _applyAllFilters(),
                  ),
                ),
                const SizedBox(width: 12),

                InkWell(
                  onTap: _navigateToFilter, 
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

          // List Event (Expanded ListView)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: MyApp.darkSlate))
                : _filteredEvents.isEmpty
                    ? _buildEmptyState()
                    : EventList(
                        events: _filteredEvents,
                        listType: EventListType.verticalSmall, 
                        scrollable: true, 
                        onRefresh: () {
                          _fetchEvents();
                        },
                      ),
          ),
        ],
      ),
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
            "No Matching events found :(",
            style: TextStyle(color: MyApp.orange),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                // 1. Reset Search
                _searchController.clear();
                
                // 2. Reset Semua Variabel Filter
                _selectedCategories = [];
                _selectedTypes = [];
                _selectedDateOrder = null;
                _selectedOwnership = 'All Event';
                
                // 3. Terapkan Ulang (Refresh List)
                _applyAllFilters();
              });
            },
            child: const Text("Reset Filter"),
          ),
        ],
      ),
    );
  }
}
