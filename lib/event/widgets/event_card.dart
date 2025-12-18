import 'package:any_venue/event/models/event.dart';
import 'package:any_venue/widgets/components/arrow_button.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final EventEntry event;
  final VoidCallback? onTap;
  final VoidCallback? onArrowTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onArrowTap,
  });

  String _formatEventDate(EventEntry event) {
    const monthAbbreviations = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = event.date.day;
    final month = monthAbbreviations[event.date.month - 1];
    final year = event.date.year;
    
    return '${event.startTime}, $day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: (event.thumbnail.isNotEmpty && Uri.parse(event.thumbnail).isAbsolute)
                  ? Image.network(
                      event.thumbnail,
                      width: 78,
                      height: 78,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderImage(),
                    )
                  : _buildPlaceholderImage(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF315672),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 16, color: Color(0xFFE9631A)),
                      const SizedBox(width: 4),
                      Text(
                        '${event.registeredCount} Registered',
                        style: const TextStyle(
                          color: Color(0xFFE9631A), 
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time_outlined, size: 16, color: Color(0xFFE9631A)),
                      const SizedBox(width: 4),
                      Text(
                        _formatEventDate(event),
                        style: const TextStyle(
                          color: Color(0xFFE9631A), 
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF7A7A90)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venueAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF7A7A90),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ArrowButton(onTap: onArrowTap), 
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.image_outlined, size: 32, color: Colors.grey),
    );
  }
}
