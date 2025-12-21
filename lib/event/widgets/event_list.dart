import 'package:flutter/material.dart';
import 'package:any_venue/event/models/event.dart';
import 'package:any_venue/event/widgets/event_card.dart';
import 'package:any_venue/event/screens/event_page_detail.dart';

enum EventListType {
  horizontalFeat, // Geser samping, Card Besar (Home)
  verticalSmall, // List ke bawah, Card Kecil (Search)
  verticalLarge // List ke bawah, Card Besar (My Events / Alternate)
}

class EventList extends StatefulWidget {
  final List<EventEntry> events;
  final Function() onRefresh;
  final EventListType listType;
  final bool scrollable;
  
  // Callback khusus untuk Owner/Actions
  final Function(EventEntry)? onEdit;
  final Function(EventEntry)? onDelete;

  const EventList({
    super.key,
    required this.events,
    required this.onRefresh,
    this.listType = EventListType.horizontalFeat,
    this.scrollable = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<EventList> createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (widget.listType) {
      case EventListType.horizontalFeat:
        return _buildHorizontalFeatList();
      case EventListType.verticalSmall:
        return _buildVerticalList(isCardSmall: true);
      case EventListType.verticalLarge:
        return _buildVerticalList(isCardSmall: false);
    }
  }

  // ==========================================
  // LAYOUT 1: HORIZONTAL (GESER SAMPING)
  // - Randomize & Limit 5
  // ==========================================
  Widget _buildHorizontalFeatList() {
    final List<EventEntry> randomEvents = List<EventEntry>.from(widget.events)..shuffle();
    final List<EventEntry> displayedEvents = randomEvents.take(5).toList();

    return SizedBox(
      height: 290,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: displayedEvents.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 260, 
            child: EventCard(
              event: displayedEvents[index],
              isSmall: false, // Card Besar
              showControls: false, // HIDE Edit/Delete on Homepage (Horizontal Layout)
              onTap: () => _navigateToDetail(displayedEvents[index]),
              onArrowTap: () => _navigateToDetail(displayedEvents[index]),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // LAYOUT 2 & 3: VERTICAL (LIST KE BAWAH)
  // - Bisa Small atau Large tergantung parameter
  // ==========================================
  Widget _buildVerticalList({required bool isCardSmall}) {
    return ListView.separated(
      physics: widget.scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: !widget.scrollable,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: widget.events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final event = widget.events[index];
        return EventCard(
          event: event,
          isSmall: isCardSmall, // Dinamis sesuai tipe
          onTap: () => _navigateToDetail(event),
          onArrowTap: () => _navigateToDetail(event),
          onEditTap: widget.onEdit != null ? () => widget.onEdit!(event) : null,
          onDeleteTap: widget.onDelete != null ? () => widget.onDelete!(event) : null,
        );
      },
    );
  }

  // Helper Navigation
  Future<void> _navigateToDetail(EventEntry event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailPage(event: event),
      ),
    );

    if (result == true) {
      widget.onRefresh();
    }
  }
}
