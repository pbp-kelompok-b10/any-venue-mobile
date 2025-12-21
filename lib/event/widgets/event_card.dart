import 'package:any_venue/event/models/event.dart';
import 'package:any_venue/widgets/components/arrow_button.dart';
import 'package:flutter/material.dart';
import 'package:any_venue/main.dart';

class EventCard extends StatelessWidget {
  final EventEntry event;
  final bool isSmall;
  final VoidCallback? onTap;
  final VoidCallback? onArrowTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;

  const EventCard({
    super.key,
    required this.event,
    this.isSmall = false,
    this.onTap,
    this.onArrowTap,
    this.onEditTap,
    this.onDeleteTap,
  });

  String get _imageUrl {
    if (event.thumbnail.isEmpty) return "";
    return 'https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/venue/proxy-image/?url=${Uri.encodeComponent(event.thumbnail)}';
  }

  String _getMonthAbbr(int month) {
    const monthAbbreviations = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthAbbreviations[month - 1];
  }

  // Helper formatting full date string untuk layout kecil
  String _formatEventDate(EventEntry event) {
    final day = event.date.day;
    final month = _getMonthAbbr(event.date.month);
    final year = event.date.year;
    return '${event.startTime}, $day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    // Check if the event is in the past
    final now = DateTime.now();
    final bool isExpired = event.date.isBefore(now) && !DateUtils.isSameDay(event.date, now);

    // KONDISI UTAMA:
    // Jika Layout Besar: TIDAK pakai Container putih pembungkus
    // Jika Layout Kecil: PAKAI Container putih pembungkus
    
    if (isSmall) {
      return Opacity(
        opacity: isExpired ? 0.6 : 1.0, // Make expired events look faded
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: MyApp.gumetalSlate.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            // SWITCH LAYOUT
            child: _buildSmallLayout(isExpired),
            ),
          ),
        );
      } else {
      return Opacity(
        opacity: isExpired ? 0.6 : 1.0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: _buildLargeLayout(context, isExpired),
        ),
      );
    }
  }

  // ==========================================
  // LAYOUT 1: LARGE
  // ==========================================
  Widget _buildLargeLayout(BuildContext context, bool isExpired) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Agar tidak memaksa tinggi full
      children: [
        // 1. GAMBAR & DATE BADGE
        Container(
          constraints: const BoxConstraints(minHeight: 160), 
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
               BoxShadow(
                color: MyApp.gumetalSlate.withOpacity(0.35), // Shadow halus di bawah gambar
                blurRadius: 12,
                offset: const Offset(0, 8), 
              ),
            ],
          ),
          child: Stack(
            children: [
              // Gambar Utama
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 180, // Tinggi gambar fixed
                  width: double.infinity, // Lebar mengikuti parent
                  child: ColorFiltered(
                    colorFilter: isExpired
                        ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                        : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                    child: _buildNetworkImage(width: double.infinity, height: 180),
                  ),
                ),
              ),
              
              // Date Badge (Kotak Putih Tanggal)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8), // Sedikit lebih kotak sesuai referensi
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getMonthAbbr(event.date.month), // "May"
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: MyApp.gumetalSlate,
                        ),
                      ),
                      Text(
                        "${event.date.day}", // "20"
                        style: const TextStyle(
                          fontSize: 14, // Ukuran angka disesuaikan
                          fontWeight: FontWeight.w800,
                          color: MyApp.gumetalSlate,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2. INFORMASI TEXT (Title, Price/Time, Location)
        Row(
          crossAxisAlignment: CrossAxisAlignment.center, 
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Event
                  Text(
                    event.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16, // Ukuran font judul sedikit diperkecil agar elegan
                      fontWeight: FontWeight.bold,
                      color: MyApp.gumetalSlate,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // WAKTU
                  Row(
                    children: [
                      const Icon(Icons.access_time_filled, size: 14, color: MyApp.orange),
                      const SizedBox(width: 4),
                      Text(
                        event.startTime, 
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: MyApp.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // LOKASI
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venueAddress,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            
            // Tombol Panah
            ArrowButton(onTap: onArrowTap),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // LAYOUT 2: SMALL
  // ==========================================
  Widget _buildSmallLayout(bool isExpired) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail with grayscale effect if expired
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: ColorFiltered(
              colorFilter: isExpired 
                  ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                  : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
              child: SizedBox(
                width: 78,
                height: 78,
                child: _buildNetworkImage(width: 78, height: 78),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Event Details
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
                    color: MyApp.gumetalSlate,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 16, color: MyApp.orange),
                    const SizedBox(width: 4),
                    Text(
                      '${event.registeredCount}',
                      style: const TextStyle(
                        color: MyApp.orange, 
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time_outlined, size: 16, color: MyApp.orange),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatEventDate(event),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: MyApp.orange, 
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.venueAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
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
          
          // Action Buttons stacked vertically (Only for Small Layout / Owner)
          if (event.isOwner) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: MyApp.gumetalSlate),
                  onPressed: onEditTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: MyApp.orange),
                  onPressed: onDeleteTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
          
          ArrowButton(onTap: onArrowTap), 
        ],
      ),
    );
  }

  Widget _buildNetworkImage({required double width, required double height}) {
    if (_imageUrl.isNotEmpty) {
      return Image.network(
        _imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : Container(
              width: width, height: height, 
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2))
            ),
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholderImage(width, height),
      );
    } else {
      return _buildPlaceholderImage(width, height);
    }
  }

  Widget _buildPlaceholderImage(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.image_outlined, size: 32, color: Colors.grey),
    );
  }
}