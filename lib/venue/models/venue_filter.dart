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

  // Mengecek apakah sebuah venue memenuhi kriteria filter saat ini
  bool matches(Venue venue, String searchQuery) {
    // 1. Search Query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
    
      final matchesName = venue.name.toLowerCase().contains(query);
      final matchesCity = venue.city.name.toLowerCase().contains(query);
      final matchesCategory = venue.category.name.toLowerCase().contains(query);
      final matchesType = venue.type.toLowerCase().contains(query);

      if (!(matchesName || matchesCity || matchesCategory || matchesType)) {
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