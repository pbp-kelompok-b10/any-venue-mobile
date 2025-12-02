import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/widgets/components/search_bar.dart';
import 'package:any_venue/venue/models/venue.dart';
import 'package:any_venue/venue/widgets/venue_list.dart';

class VenuePage extends StatefulWidget {
  final String? initialCategory; 

  const VenuePage({super.key, this.initialCategory});

  @override
  State<VenuePage> createState() => _VenuePageState();
}

class _VenuePageState extends State<VenuePage> {
  // STATE FILTER
  String _searchQuery = "";
  
  // Filter Variables
  String? _selectedCity;
  String? _selectedCategory;
  String? _selectedType;
  RangeValues _priceRange = const RangeValues(0, 5000000); // Default range 0 - 5 Juta

  // Data
  Future<List<Venue>>? _venueFuture;
  List<Venue> _allVenues = []; // Simpan semua data untuk keperluan filter

  @override
  void initState() {
    super.initState();
    // Set kategori awal
    _selectedCategory = widget.initialCategory;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final request = context.read<CookieRequest>();
        setState(() {
          _venueFuture = _fetchAllVenues(request);
        });
      }
    });
  }

  Future<List<Venue>> _fetchAllVenues(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/venue/api/venues-flutter/');
    List<Venue> list = [];
    for (var d in response) {
      if (d != null) list.add(Venue.fromJson(d));
    }
    _allVenues = list;
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF293241)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "All Venues",
          style: TextStyle(color: MyApp.gumetalSlate, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // 1. SEARCH BAR & FILTER BUTTONS
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              children: [
                CustomSearchBar(
                  hintText: "Cari Venue di sini...",
                  readOnly: false,
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                ),
                
                const SizedBox(height: 12),

                // TOMBOL FILTER
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterButton("City", _selectedCity, () => _showSelectionModal("City")),
                      const SizedBox(width: 8),
                      _buildFilterButton("Category", _selectedCategory, () => _showSelectionModal("Category")),
                      const SizedBox(width: 8),
                      _buildFilterButton("Type", _selectedType, () => _showSelectionModal("Type")),
                      const SizedBox(width: 8),
                      _buildFilterButton("Price", 
                        _priceRange.end < 5000000 ? "Set" : null, // Label logic
                        () => _showPriceModal(),
                        icon: Icons.attach_money
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // LIST VENUE
          Expanded(
            child: FutureBuilder<List<Venue>>(
              future: _venueFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Tidak ada venue."));
                }

                final allVenues = snapshot.data!;
                
                // --- LOGIKA FILTER UTAMA ---
                final filteredVenues = allVenues.where((venue) {
                  // 1. Search Query
                  final matchQuery = venue.name.toLowerCase().contains(_searchQuery);
                  
                  // 2. City Filter
                  bool matchCity = true;
                  if (_selectedCity != null) {
                    matchCity = venue.city.name == _selectedCity;
                  }

                  // 3. Category Filter
                  bool matchCategory = true;
                  if (_selectedCategory != null) {
                    matchCategory = venue.category.name == _selectedCategory;
                  }

                  // 4. Type Filter
                  bool matchType = true;
                  if (_selectedType != null) {
                    matchType = venue.type == _selectedType;
                  }

                  // 5. Price Range Filter
                  bool matchPrice = true;
                  matchPrice = venue.price >= _priceRange.start && venue.price <= _priceRange.end;

                  // GABUNGKAN SEMUA DENGAN 'AND' (&&)
                  return matchQuery && matchCity && matchCategory && matchType && matchPrice;
                }).toList();

                if (filteredVenues.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_list_off, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text("Tidak ada venue yang cocok nih :(", style: TextStyle(color: MyApp.orange)),
                        TextButton(
                          onPressed: _resetFilters, 
                          child: const Text("Reset Filter")
                        )
                      ],
                    ),
                  );
                }

                // List
                return VenueList(
                  venues: filteredVenues,
                  isLarge: false, 
                  scrollable: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: TOMBOL FILTER KAPSUL ---
  Widget _buildFilterButton(String label, String? selectedValue, VoidCallback onTap, {IconData? icon}) {
    final bool isActive = selectedValue != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? MyApp.darkSlate : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? MyApp.darkSlate : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Text(
              isActive ? selectedValue! : label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              icon ?? Icons.keyboard_arrow_down, 
              size: 16, 
              color: isActive ? Colors.white : Colors.grey[700],
            )
          ],
        ),
      ),
    );
  }

  // --- LOGIC MODAL: PILIHAN LIST (CITY, CATEGORY, TYPE) ---
  void _showSelectionModal(String type) {
    // Ambil data unik dari list venue yang sudah difetch
    Set<String> items = {};
    if (type == "City") {
      items = _allVenues.map((v) => v.city.name).toSet();
    } else if (type == "Category") {
      items = _allVenues.map((v) => v.category.name).toSet();
    } else if (type == "Type") {
      items = {"Indoor", "Outdoor"}; 
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Select $type", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if ((type == "City" && _selectedCity != null) || 
                      (type == "Category" && _selectedCategory != null) ||
                      (type == "Type" && _selectedType != null))
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (type == "City") _selectedCity = null;
                          if (type == "Category") _selectedCategory = null;
                          if (type == "Type") _selectedType = null;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Clear"),
                    )
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: items.map((item) {
                  bool isSelected = false;
                  if (type == "City") isSelected = item == _selectedCity;
                  if (type == "Category") isSelected = item == _selectedCategory;
                  if (type == "Type") isSelected = item == _selectedType;

                  return ChoiceChip(
                    label: Text(item),
                    selected: isSelected,
                    selectedColor: MyApp.orange.withOpacity(0.2),
                    labelStyle: TextStyle(color: isSelected ? MyApp.orange : Colors.black),
                    onSelected: (bool selected) {
                      setState(() {
                        if (type == "City") _selectedCity = selected ? item : null;
                        if (type == "Category") _selectedCategory = selected ? item : null;
                        if (type == "Type") _selectedType = selected ? item : null;
                      });
                      Navigator.pop(context); // Tutup modal setelah pilih
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // --- LOGIC MODAL: PRICE RANGE ---
  void _showPriceModal() {
    // Variable sementara agar slider bisa digeser real-time di modal
    RangeValues tempRange = _priceRange;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Rentang Harga", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          setState(() => _priceRange = const RangeValues(0, 5000000));
                          Navigator.pop(context);
                        },
                        child: const Text("Reset"),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  RangeSlider(
                    values: tempRange,
                    min: 0,
                    max: 5000000, // Max 5 Juta 
                    divisions: 50,
                    activeColor: MyApp.orange,
                    labels: RangeLabels(
                      "Rp ${tempRange.start.round()}", 
                      "Rp ${tempRange.end.round()}"
                    ),
                    onChanged: (RangeValues values) {
                      setStateModal(() => tempRange = values); // Update tampilan modal
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Rp ${tempRange.start.round()}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Rp ${tempRange.end.round()}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyApp.darkSlate,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() => _priceRange = tempRange); // Simpan ke state utama
                        Navigator.pop(context);
                      },
                      child: const Text("Apply Filter"),
                    ),
                  )
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedCity = null;
      _selectedCategory = null;
      _selectedType = null;
      _priceRange = const RangeValues(0, 5000000);
      _searchQuery = "";
    });
  }
}