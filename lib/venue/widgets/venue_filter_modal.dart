import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/widgets/components/button.dart';
import 'package:any_venue/venue/models/venue_filter.dart';

class VenueFilterModal extends StatefulWidget {
  final VenueFilter currentFilter;
  final List<String> cities;
  final List<String> categories;
  final Function(VenueFilter) onApply; // Callback saat tombol Apply ditekan

  const VenueFilterModal({
    super.key,
    required this.currentFilter,
    required this.cities,
    required this.categories,
    required this.onApply,
  });

  @override
  State<VenueFilterModal> createState() => _VenueFilterModalState();
}

class _VenueFilterModalState extends State<VenueFilterModal> {
  // State Lokal Modal
  late VenueFilter _tempFilter;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;

  final List<String> _types = ["Indoor", "Outdoor"];

  @override
  void initState() {
    super.initState();
    // Copy filter dari parent agar perubahan tidak langsung ngefek sebelum di-Apply
    _tempFilter = widget.currentFilter.copy();

    _minPriceController = TextEditingController(
      text: _tempFilter.minPrice == 0 ? "" : _tempFilter.minPrice.round().toString(),
    );

    _maxPriceController = TextEditingController(
      text: (_tempFilter.maxPrice.isInfinite || _tempFilter.maxPrice == 5000000)
          ? ""
          : _tempFilter.maxPrice.round().toString(),
    );
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                "Filter",
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

          // --- CONTENT (SCROLLABLE) ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("City"),
                  _buildChipGroup(widget.cities, _tempFilter.city, (val) {
                    setState(() => _tempFilter.city = val);
                  }),

                  _buildSectionTitle("Category"),
                  _buildChipGroup(widget.categories, _tempFilter.category, (val) {
                    setState(() => _tempFilter.category = val);
                  }),

                  _buildSectionTitle("Type"),
                  _buildChipGroup(_types, _tempFilter.type, (val) {
                    setState(() => _tempFilter.type = val);
                  }),

                  _buildSectionTitle("Price Range"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPriceInput(_minPriceController, "Min Price"),
                      ),
                      const SizedBox(width: 12),
                      const Text("-", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPriceInput(_maxPriceController, "Max Price"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // --- BUTTON APPLY ---
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

  void _clearAll() {
    setState(() {
      _tempFilter.reset();
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  void _applyFilter() {
    // Update nilai harga dari controller ke object filter
    _tempFilter.minPrice = double.tryParse(_minPriceController.text) ?? 0;
    _tempFilter.maxPrice = double.tryParse(_maxPriceController.text) ?? double.infinity;

    // Kirim data balik ke VenuePage
    widget.onApply(_tempFilter);
    Navigator.pop(context);
  }

  // --- WIDGET HELPER ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  Widget _buildChipGroup(List<String> items, String? selectedItem, Function(String?) onSelect) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final bool isSelected = item == selectedItem;
        return GestureDetector(
          onTap: () => onSelect(isSelected ? null : item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? MyApp.gumetalSlate : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? MyApp.gumetalSlate : Colors.transparent,
              ),
            ),
            child: Text(
              item,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceInput(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: MyApp.gumetalSlate)),
        prefixText: "Rp ",
        prefixStyle: const TextStyle(color: Colors.black, fontSize: 13),
      ),
    );
  }
}