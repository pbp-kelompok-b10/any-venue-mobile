import 'package:any_venue/main.dart';
import 'package:any_venue/widgets/components/button.dart';
import 'package:flutter/material.dart';

class EventFilterPage extends StatefulWidget {
  const EventFilterPage({super.key});

  @override
  State<EventFilterPage> createState() => _EventFilterPageState();
}

class _EventFilterPageState extends State<EventFilterPage> {
  // Expansion state - All set to false initially
  final Map<String, bool> _isExpanded = {
    'Cities': false,
    'Category': false,
    'Type': false,
    'Date': false,
  };

  // Selection state
  final Set<String> _selectedCities = {};
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedTypes = {};
  String? _selectedDate;

  // Filter Options
  final List<String> _cities = [
    "Depok", "Jakarta Pusat", "Jakarta Selatan", "Jakarta Timur", "Tangerang", "Tangerang Selatan"
  ];
  final List<String> _categories = [
    "Badminton", "Basket", "Futsal", "Golf", "Mini Soccer", "Padel", "Pickleball", "Sepak Bola", "Squash", "Tenis", "Tenis Meja"
  ];
  final List<String> _types = ["Indoor", "Outdoor"];
  final List<String> _dates = ["Closest", "Fartest"];

  void _clearAll() {
    setState(() {
      _selectedCities.clear();
      _selectedCategories.clear();
      _selectedTypes.clear();
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // --- Header ---
              SliverAppBar(
                backgroundColor: const Color(0xFFFAFAFA),
                surfaceTintColor: Colors.transparent,
                pinned: true,
                forceElevated: true,
                shadowColor: const Color(0x0C683BFC),
                elevation: 8,
                title: const Text(
                  'Filter',
                  style: TextStyle(
                    color: Color(0xFF13123A),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF13123A)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Center(
                      child: InkWell(
                        onTap: _clearAll,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: MyApp.orange,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFFD5BE)),
                          ),
                          child: const Text(
                            'Clear All',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // --- Filter Content ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterSection('Cities', _cities, _selectedCities),
                      const Divider(height: 1),
                      _buildFilterSection('Category', _categories, _selectedCategories),
                      const Divider(height: 1),
                      _buildFilterSection('Type', _types, _selectedTypes),
                      const Divider(height: 1),
                      _buildDateSection(),
                      const SizedBox(height: 120), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- Bottom Apply Button ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 34),
              color: Colors.white,
              child: CustomButton(
                text: 'Apply Filter',
                onPressed: () {
                  // Pass back the selected filters
                  Navigator.pop(context, {
                    'cities': _selectedCities.toList(),
                    'categories': _selectedCategories.toList(),
                    'types': _selectedTypes.toList(),
                    'date': _selectedDate,
                  });
                },
                isFullWidth: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options, Set<String> selectionSet) {
    bool isExpanded = _isExpanded[title] ?? false;
    int selectedCount = selectionSet.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded[title] = !isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1F2024),
                      fontSize: 16,
                      fontWeight: FontWeight.w600, // Balanced weight
                    ),
                  ),
                ),
                if (selectedCount > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: MyApp.darkSlate,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$selectedCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF8F9098),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                bool isSelected = selectionSet.contains(option);
                return _buildChip(
                  label: option,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectionSet.remove(option);
                      } else {
                        selectionSet.add(option);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildDateSection() {
    String title = 'Date';
    bool isExpanded = _isExpanded[title] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded[title] = !isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1F2024),
                      fontSize: 16,
                      fontWeight: FontWeight.w600, // Balanced weight
                    ),
                  ),
                ),
                if (_selectedDate != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: MyApp.darkSlate,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF8F9098),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _dates.map((option) {
                bool isSelected = _selectedDate == option;
                return _buildChip(
                  label: option,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedDate = isSelected ? null : option;
                    });
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? MyApp.darkSlate : const Color(0xFFE8E8EC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : MyApp.darkSlate,
            fontSize: 14, // Increased from 12 to 14 for better balance
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
