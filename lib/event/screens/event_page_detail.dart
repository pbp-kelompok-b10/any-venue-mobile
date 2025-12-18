import 'package:any_venue/event/models/event.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/widgets/components/button.dart';
import 'package:any_venue/widgets/components/label.dart';
import 'package:flutter/material.dart';

class EventDetailPage extends StatefulWidget {
  final EventEntry event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool _isExpanded = false; // Status untuk Read More

  String _formatEventDate(DateTime date) {
    const monthAbbreviations = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${monthAbbreviations[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFFFAFAFA),
                surfaceTintColor: Colors.transparent,
                pinned: true,
                floating: true,
                forceElevated: true,
                shadowColor: Colors.black.withOpacity(0.08),
                title: const Text('Detail Event',
                  style: TextStyle(
                    color: Color(0xFF13123A), 
                    fontSize: 18, 
                    fontWeight: FontWeight.w700
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF13123A)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 238, 
                      width: double.infinity,
                      child: (widget.event.thumbnail.isNotEmpty && Uri.parse(widget.event.thumbnail).isAbsolute)
                          ? Image.network(
                              widget.event.thumbnail,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) =>
                                  progress == null ? child : const Center(child: CircularProgressIndicator()),
                              errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                            )
                          : _buildPlaceholderImage(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              InfoLabel(
                                label: widget.event.startTime,
                                icon: Icons.access_time_filled, 
                                color: MyApp.orange,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                fontSize: 12,
                              ),
                              const SizedBox(width: 12),
                              InfoLabel(
                                label: _formatEventDate(widget.event.date),
                                icon: Icons.calendar_month,
                                color: MyApp.darkSlate,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                fontSize: 12,
                              ),
                              const SizedBox(width: 12),
                              InfoLabel(
                                label: widget.event.venueCategory,
                                icon: Icons.sports_soccer,
                                color: MyApp.gumetalSlate,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                fontSize: 12,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 361,
                            child: Text(
                              widget.event.name,
                              style: const TextStyle(
                                color: Colors.black, 
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                height: 1.50,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildStatsCard(),
                          const SizedBox(height: 24),
                          _buildOwnerInfo(),
                          const SizedBox(height: 24),
                          _buildDescription(),
                          const SizedBox(height: 24),
                          _buildLocation(),
                          const SizedBox(height: 120),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          _buildFloatingJoinButton(),
        ],
      ),
    );
  }
  
  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFFEBEBEB),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('No Image Available', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadows: [
          BoxShadow(
            color: const Color(0x66315672),
            blurRadius: 32,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _buildStatItem(Icons.people, 'Registrants', '${widget.event.registeredCount}')),
          Expanded(child: _buildStatItem(Icons.stadium_rounded, 'Type', widget.event.venueType)), 
          Expanded(child: _buildStatItem(Icons.location_on, 'Venue', widget.event.venueName)),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF7A7A90)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Color(0xFF7A7A90), fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: MyApp.orange,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: MyApp.darkSlate,
          child: Text(
            widget.event.owner.isNotEmpty ? widget.event.owner[0].toUpperCase() : '',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.event.owner,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
              const Text(
                'Owner',
                style: TextStyle(
                  color: Color(0xFF7A7A90),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    const textLimit = 150;
    final isLongText = widget.event.description.length > textLimit;
    
    // Logika tampilan teks berdasarkan status _isExpanded
    final displayText = (_isExpanded || !isLongText) 
        ? widget.event.description 
        : '${widget.event.description.substring(0, textLimit)}...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          displayText, 
          style: const TextStyle(color: Color(0xFF7A7A90), fontSize: 14, height: 1.5),
        ),
        if (isLongText)
          TextButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded; // Toggle status
              });
            },
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
            child: Text(
              _isExpanded ? 'Read less' : 'Read more', 
              style: const TextStyle(color: MyApp.darkSlate, decoration: TextDecoration.underline)
            ),
          ),
      ],
    );
  }

  Widget _buildLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          widget.event.venueAddress,
          style: const TextStyle(color: Color(0xFF7A7A90), fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildFloatingJoinButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 34),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0x00FAFAFA),
              const Color(0xFFFAFAFA).withOpacity(0.8),
              const Color(0xFFFAFAFA),
            ],
            stops: const [0, 0.4, 0.8],
          ),
        ),
        child: CustomButton(
          text: 'Join Event',
          onPressed: () {
            print('Join Event button clicked!');
          },
          isFullWidth: true,
        ),
      ),
    );
  }
}
