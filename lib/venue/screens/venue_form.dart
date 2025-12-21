import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:any_venue/main.dart';
import 'package:any_venue/widgets/components/button.dart';
import 'package:any_venue/widgets/components/app_bar.dart';
import 'package:any_venue/widgets/toast.dart';

import 'package:any_venue/venue/models/venue.dart';
import 'package:any_venue/venue/models/city.dart';
import 'package:any_venue/venue/models/category.dart';

class VenueFormPage extends StatefulWidget {
  final Venue? venue; // Null = Create, Not Null = Edit

  const VenueFormPage({super.key, this.venue});

  @override
  State<VenueFormPage> createState() => _VenueFormPageState();
}

class _VenueFormPageState extends State<VenueFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers & State Input
  String _name = "";
  int _price = 0;
  String _address = "";
  String _description = "";
  String _imageUrl = "";
  String _type = "Indoor";

  // State untuk Dropdown Data Master
  String? _selectedCity;
  String? _selectedCategory;

  // List Penampung Data dari API
  List<City> _cityList = [];
  List<Category> _categoryList = [];
  bool _isLoadingData = true; // Loading saat fetch kota/kategori

  final List<String> _types = ["Indoor", "Outdoor"];

  @override
  void initState() {
    super.initState();

    // 1. Fetch Data Kota & Kategori saat form dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMasterData();
    });

    // 2. Jika Mode Edit, isi form dengan data lama
    if (widget.venue != null) {
      _name = widget.venue!.name;
      _price = widget.venue!.price;
      _address = widget.venue!.address;
      _description = widget.venue!.description;
      _imageUrl = widget.venue!.imageUrl;
      _type = widget.venue!.type;

      // Set nilai awal dropdown
      _selectedCity = widget.venue!.city.name;
      _selectedCategory = widget.venue!.category.name;
    }
  }

  // Fungsi mengambil data Kota & Kategori dari Django
  Future<void> _fetchMasterData() async {
    final request = context.read<CookieRequest>();
    try {
      const String baseUrl = "https://keisha-vania-anyvenue.pbp.cs.ui.ac.id";

      // Ambil Data Cities
      final responseCities = await request.get(
        '$baseUrl/venue/api/cities-flutter/',
      );
      final List<City> cities = [];
      for (var d in responseCities) {
        if (d != null) cities.add(City.fromJson(d));
      }

      // Ambil Data Categories
      final responseCategories = await request.get(
        '$baseUrl/venue/api/categories-flutter/',
      );
      final List<Category> categories = [];
      for (var d in responseCategories) {
        if (d != null) categories.add(Category.fromJson(d));
      }

      if (mounted) {
        setState(() {
          _cityList = cities;
          _categoryList = categories;
          _isLoadingData = false;

          if (_selectedCity != null &&
              !_cityList.any((c) => c.name == _selectedCity)) {
            _selectedCity = null;
          }
          if (_selectedCategory != null &&
              !_categoryList.any((c) => c.name == _selectedCategory)) {
            _selectedCategory = null;
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching master data: $e");
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEdit = widget.venue != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Create New Venue"),
      // Tampilkan Loading jika data dropdown belum siap
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NAMA VENUE
                    _buildSectionLabel("Venue Name"),
                    TextFormField(
                      initialValue: _name,
                      decoration: _inputDecoration(
                        "e.g. Gor Badminton Sejahtera",
                      ),
                      onChanged: (val) => _name = val,
                      validator: (val) =>
                          val!.isEmpty ? "Name cannot be empty" : null,
                    ),
                    const SizedBox(height: 20),

                    // HARGA & TIPE
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel("Price (Rp)"),
                              TextFormField(
                                initialValue: _price > 0
                                    ? _price.toString()
                                    : "",
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration("50000"),
                                onChanged: (val) =>
                                    _price = int.tryParse(val) ?? 0,
                                // PERBAIKAN 1: Tambahkan validasi batas angka (Max 32-bit Integer)
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return "Required";
                                  }
                                  final number = int.tryParse(val);
                                  if (number == null) {
                                    return "Invalid number";
                                  }
                                  // Batas aman integer 32-bit (sekitar 2.1 Miliar)
                                  if (number > 2147483647) { 
                                    return "Price is too high!";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel("Type"),
                              DropdownButtonFormField<String>(
                                initialValue: _type,
                                items: _types
                                    .map(
                                      (t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(t),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _type = val!),
                                decoration: _inputDecoration("Select"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // CITY & CATEGORY
                    Row(
                      children: [
                        // Dropdown City
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel("City"),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedCity,
                                hint: const Text("Select City"),
                                items: _cityList.map((city) {
                                  return DropdownMenuItem<String>(
                                    value: city.name,
                                    child: Text(
                                      city.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedCity = val),
                                validator: (val) =>
                                    val == null ? "Required" : null,
                                decoration: _inputDecoration("Select"),
                                isExpanded: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Dropdown Category
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel("Category"),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                hint: const Text("Select Category"),
                                items: _categoryList.map((cat) {
                                  return DropdownMenuItem<String>(
                                    value: cat.name,
                                    child: Text(
                                      cat.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedCategory = val),
                                validator: (val) =>
                                    val == null ? "Required" : null,
                                decoration: _inputDecoration("Select"),
                                isExpanded: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ADDRESS
                    _buildSectionLabel("Full Address"),
                    TextFormField(
                      initialValue: _address,
                      maxLines: 2,
                      decoration: _inputDecoration(
                        "Street name, number, district...",
                      ),
                      onChanged: (val) => _address = val,
                      validator: (val) =>
                          val!.isEmpty ? "Address is required" : null,
                    ),
                    const SizedBox(height: 20),

                    // DESCRIPTION
                    _buildSectionLabel("Description"),
                    TextFormField(
                      initialValue: _description,
                      maxLines: 4,
                      decoration: _inputDecoration(
                        "Describe your venue facilities...",
                      ),
                      onChanged: (val) => _description = val,
                      validator: (val) =>
                          val!.isEmpty ? "Description is required" : null,
                    ),
                    const SizedBox(height: 20),

                    // IMAGE URL
                    _buildSectionLabel("Image URL"),
                    TextFormField(
                      initialValue: _imageUrl,
                      decoration: _inputDecoration("https://..."),
                      onChanged: (val) => _imageUrl = val,
                      validator: (val) =>
                          val!.isEmpty ? "Image URL is required" : null,
                    ),

                    const SizedBox(height: 40),

                    // TOMBOL SAVE (PAKAI CUSTOM BUTTON)
                    CustomButton(
                      text: isEdit ? "Update Venue" : "Create Venue",
                      gradientColors: const [
                        MyApp.gumetalSlate,
                        MyApp.darkSlate,
                      ],
                      isFullWidth: true,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          const String baseUrl =
                              "https://keisha-vania-anyvenue.pbp.cs.ui.ac.id";
                          String url = isEdit
                              ? '$baseUrl/venue/api/edit-flutter/${widget.venue!.id}/'
                              : '$baseUrl/venue/api/create-flutter/';

                          try {
                            final response = await request.postJson(
                              url,
                              jsonEncode({
                                "name": _name,
                                "price": _price,
                                "city": _selectedCity,
                                "category": _selectedCategory,
                                "type": _type,
                                "address": _address,
                                "description": _description,
                                "image_url": _imageUrl,
                              }),
                            );

                            if (context.mounted) {
                              if (response['status'] == 'success') {
                                // SUKSES
                                CustomToast.show(
                                  context,
                                  message: isEdit
                                      ? "Venue Updated!"
                                      : "Venue Created!",
                                  subMessage: response['message'] ??
                                      "Your venue is ready.",
                                  isError: false,
                                );

                                Navigator.pop(context, true);
                              } else {
                                CustomToast.show(
                                  context,
                                  message: "Action Failed",
                                  subMessage: response['message'] ??
                                      "An error occurred on the server.",
                                  isError: true,
                                );
                              }
                            }
                          } catch (e) {
                            debugPrint("Error saving venue: $e");
                            if (context.mounted) {
                              CustomToast.show(
                                context,
                                message: "System Error",
                                subMessage: e.toString(), 
                                isError: true,
                              );
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: MyApp.gumetalSlate,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MyApp.darkSlate, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
