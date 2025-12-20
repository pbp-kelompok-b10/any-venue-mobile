import 'package:any_venue/event/models/event.dart';
import 'package:any_venue/event/screens/event_filter.dart';
import 'package:any_venue/event/screens/event_form.dart';
import 'package:any_venue/event/screens/event_page_detail.dart';
import 'package:any_venue/event/widgets/event_card.dart';
import 'package:any_venue/event/widgets/filter_event.dart';
import 'package:any_venue/widgets/components/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  List<EventEntry> _allEvents = [];
  late List<EventEntry> _filteredEvents;
  bool _isLoading = true;

  final _searchController = TextEditingController();

  List<String> _selectedCategories = [];
  List<String> _selectedTypes = [];
  String? _selectedDateOrder;

  @override
  void initState() {
    super.initState();
    _filteredEvents = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEvents();
    });
  }

  Future<void> _fetchEvents() async {
    final request = context.read<CookieRequest>();
    setState(() => _isLoading = true);

    try {
      // Updated to production URL
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
        return matchesSearch && matchesCategory && matchesType;
      }).toList();

      List<EventEntry> activeEvents = results.where((e) => e.date.isAfter(now) || DateUtils.isSameDay(e.date, now)).toList();
      List<EventEntry> pastEvents = results.where((e) => e.date.isBefore(now) && !DateUtils.isSameDay(e.date, now)).toList();

      if (_selectedDateOrder == 'Closest') {
        activeEvents.sort((a, b) => a.date.compareTo(b.date));
      } else if (_selectedDateOrder == 'Fartest') {
        activeEvents.sort((a, b) => b.date.compareTo(a.date));
      }
      _filteredEvents = [...activeEvents, ...pastEvents];
    });
  }

  void _navigateToDetail(EventEntry event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventDetailPage(event: event)),
    );
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
                _fetchEvents(); 
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(response['message'] ?? "Error occurred"),
                  backgroundColor: Colors.red,
                ));
              }
            }, 
            child: const Text('Delete', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToFilter() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventFilterPage(
          initialCategories: _selectedCategories,
          initialTypes: _selectedTypes,
          initialDate: _selectedDateOrder,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
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
            title: const Text('Events',
              style: TextStyle(color: Color(0xFF13123A), fontSize: 16, fontWeight: FontWeight.w700),
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
                  FilterEventButton(onTap: _navigateToFilter),
                ],
              ), 
            ),
          ),
          _isLoading
          ? const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          : _filteredEvents.isEmpty 
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
                        onEditTap: () => _navigateToForm(event: event),
                        onDeleteTap: () => _deleteEvent(event),
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
