import 'package:any_venue/main.dart';
import 'package:any_venue/widgets/components/button.dart';
import 'package:flutter/material.dart';

class EventFilterPage extends StatefulWidget {
  final List<String> initialCategories;
  final List<String> initialTypes;
  final String? initialDate;

  const EventFilterPage({
    super.key,
    this.initialCategories = const [],
    this.initialTypes = const [],
    this.initialDate,
  });

  @override
  State<EventFilterPage> createState() => _EventFilterPageState();
}

class _EventFilterPageState extends State<EventFilterPage> {
  // Expansion state - All set to false initially
  final Map<String, bool> _isExpanded = {
    'Category': false,
    'Type': false,
    'Date': false,
  };

  // Selection state
  late Set<String> _selectedCategories;
  late Set<String> _selectedTypes;
  String? _selectedDate;

  // Filter Options
  final List<String> _categories = [
    "Badminton", "Basket", "Futsal", "Golf", "Mini Soccer", "Padel", "Pickleball", "Sepak Bola", "Squash", "Tenis", "Tenis Meja"
  ];
  final List<String> _types = ["Indoor", "Outdoor"];
  final List<String> _dates = ["Closest", "Farthest"];

  @override
  void initState() {
    super.initState();
    // Initialize with data from the previous state
    _selectedCategories = Set.from(widget.initialCategories);
    _selectedTypes = Set.from(widget.initialTypes);
    _selectedDate = widget.initialDate;

    // Expand sections that already have selected values
    if (_selectedCategories.isNotEmpty) _isExpanded['Category'] = true;
    if (_selectedTypes.isNotEmpty) _isExpanded['Type'] = true;
    if (_selectedDate != null) _isExpanded['Date'] = true;
  }

  void _clearAll() {
    setState(() {
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
                      fontWeight: FontWeight.w600,
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
                      fontWeight: FontWeight.w600,
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
