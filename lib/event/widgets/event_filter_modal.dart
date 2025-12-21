import 'package:flutter/material.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/widgets/components/button.dart';

class EventFilterModal extends StatefulWidget {
  final List<String> initialCategories;
  final List<String> initialTypes;
  final String? initialDate;
  final String initialOwnership;
  final bool isOwner;

  const EventFilterModal({
    super.key,
    this.initialCategories = const [],
    this.initialTypes = const [],
    this.initialDate,
    this.initialOwnership = 'All Event',
    required this.isOwner,
  });

  @override
  State<EventFilterModal> createState() => _EventFilterModalState();
}

class _EventFilterModalState extends State<EventFilterModal> {
  // --- STATE  ---
  late Set<String> _selectedCategories;
  late Set<String> _selectedTypes;
  late String _selectedOwnership;
  String? _selectedDate;

  // Options
  final List<String> _ownerships = ["My Event", "All Event"];
  final List<String> _categories = [
    "Badminton", "Basket", "Futsal", "Golf", "Mini Soccer", 
    "Padel", "Pickleball", "Sepak Bola", "Squash", "Tenis", "Tenis Meja"
  ];
  final List<String> _types = ["Indoor", "Outdoor"];
  final List<String> _dates = ["Closest", "Farthest"];

  @override
  void initState() {
    super.initState();
    _selectedCategories = Set.from(widget.initialCategories);
    _selectedTypes = Set.from(widget.initialTypes);
    _selectedOwnership = widget.initialOwnership;
    _selectedDate = widget.initialDate;
  }

  void _clearAll() {
    setState(() {
      _selectedCategories.clear();
      _selectedTypes.clear();
      _selectedDate = null;
      _selectedOwnership = 'All Event';
    });
  }

  void _applyFilter() {
    // Mengembalikan data sebagai Map
    Navigator.pop(context, {
      'categories': _selectedCategories.toList(),
      'types': _selectedTypes.toList(),
      'date': _selectedDate,
      'ownership': _selectedOwnership,
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- UI STRUCTURE ---
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                "Filter Event",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _clearAll,
                style: TextButton.styleFrom(
                  backgroundColor: MyApp.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Clear All"),
              ),
            ],
          ),
          const Divider(),

          // 2. CONTENT SCROLLABLE
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section: Ownership (Only for Owner)
                  if (widget.isOwner) ...[
                    _buildSectionTitle("Ownership"),
                    _buildSingleSelectGroup(_ownerships, _selectedOwnership, (val) {
                      if (val != null) setState(() => _selectedOwnership = val);
                    }),
                  ],

                  // Section: Category (Multi-select)
                  _buildSectionTitle("Category"),
                  _buildMultiSelectGroup(_categories, _selectedCategories),

                  // Section: Type (Multi-select)
                  _buildSectionTitle("Type"),
                  _buildMultiSelectGroup(_types, _selectedTypes),

                  // Section: Date (Single-select / Toggle)
                  _buildSectionTitle("Date"),
                  _buildSingleSelectGroup(_dates, _selectedDate, (val) {
                    setState(() => _selectedDate = val == _selectedDate ? null : val);
                  }),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 3. APPLY BUTTON
          CustomButton(
            text: "Apply Filter",
            isFullWidth: true,
            borderRadius: 12,
            gradientColors: const [MyApp.gumetalSlate, MyApp.darkSlate],
            onPressed: _applyFilter,
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER (Style Venue) ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  // Helper untuk Single Selection (Date / Ownership)
  Widget _buildSingleSelectGroup(List<String> items, String? selectedItem, Function(String?) onSelect) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final bool isSelected = item == selectedItem;
        return GestureDetector(
          onTap: () => onSelect(item),
          child: _buildChipStyle(item, isSelected),
        );
      }).toList(),
    );
  }

  // Helper untuk Multi Selection (Category / Type)
  Widget _buildMultiSelectGroup(List<String> items, Set<String> selectionSet) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final bool isSelected = selectionSet.contains(item);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectionSet.remove(item);
              } else {
                selectionSet.add(item);
              }
            });
          },
          child: _buildChipStyle(item, isSelected),
        );
      }).toList(),
    );
  }

  // Style Chip
  Widget _buildChipStyle(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? MyApp.gumetalSlate : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? MyApp.gumetalSlate : Colors.transparent,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}