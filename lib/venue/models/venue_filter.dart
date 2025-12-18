import 'package:any_venue/venue/models/venue.dart';

class VenueFilter {
  String? city;
  String? category;
  String? type;
  double minPrice;
  double maxPrice;

  VenueFilter({
    this.city,
    this.category,
    this.type,
    this.minPrice = 0,
    this.maxPrice = double.infinity,
  });

  // Fungsi untuk Reset Filter ke default
  void reset() {
    city = null;
    category = null;
    type = null;
    minPrice = 0;
    maxPrice = double.infinity;
  }

  // LOGIKA FILTER DIPISAH DI SINI
  // Mengecek apakah sebuah venue memenuhi kriteria filter saat ini
  bool matches(Venue venue, String searchQuery) {
    // 1. Search Query
    if (searchQuery.isNotEmpty) {
      if (!venue.name.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }
    }

    // 2. City
    if (city != null && venue.city.name != city) {
      return false;
    }

    // 3. Category
    if (category != null && venue.category.name != category) {
      return false;
    }

    // 4. Type
    if (type != null && venue.type != type) {
      return false;
    }

    // 5. Price
    if (venue.price < minPrice || venue.price > maxPrice) {
      return false;
    }

    return true;
  }

  // Membuat copy object baru (agar tidak merusak state asli saat edit di modal)
  VenueFilter copy() {
    return VenueFilter(
      city: city,
      category: category,
      type: type,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }
}