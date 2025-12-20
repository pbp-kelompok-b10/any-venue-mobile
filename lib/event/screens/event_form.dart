import 'dart:convert';
import 'package:any_venue/event/models/event.dart';
import 'package:any_venue/venue/models/venue.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/widgets/components/button.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EventFormPage extends StatefulWidget {
  final EventEntry? event; // If provided, we are in Edit mode

  const EventFormPage({super.key, this.event});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _thumbnailController;
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  // Venue Dropdown State
  List<Venue> _ownerVenues = [];
  Venue? _selectedVenue;
  bool _isLoadingVenues = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event?.name ?? "");
    _descriptionController = TextEditingController(text: widget.event?.description ?? "");
    _thumbnailController = TextEditingController(text: widget.event?.thumbnail ?? "");
    
    if (widget.event != null) {
      _selectedDate = widget.event!.date;
      final parts = widget.event!.startTime.split(':');
      if (parts.length == 2) {
        _selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }

    // Fetch venues owned by this owner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOwnerVenues();
    });
  }

  Future<void> _fetchOwnerVenues() async {
    final request = context.read<CookieRequest>();
    try {
      // Get all venues from server
      final response = await request.get('http://localhost:8000/venue/api/venues-flutter/'); 
      
      final List<Venue> list = [];
      // Use current logged in username to match ownership
      final String currentUsername = request.jsonData['username'] ?? "";

      for (var d in response) {
        if (d != null) {
          Venue v = Venue.fromJson(d);
          // Only add if the owner's username matches
          if (v.owner.username == currentUsername) {
            list.add(v);
          }
        }
      }

      setState(() {
        _ownerVenues = list;
        _isLoadingVenues = false;
        
        if (widget.event != null) {
          _selectedVenue = _ownerVenues.firstWhere(
            (v) => v.name == widget.event!.venueName,
            orElse: () => _ownerVenues.isNotEmpty ? _ownerVenues.first : throw Exception("No venues found"),
          );
        }
      });
    } catch (e) {
      debugPrint("Error fetching venues: $e");
      if (mounted) setState(() => _isLoadingVenues = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate?.isBefore(tomorrow) == true ? tomorrow : (_selectedDate ?? tomorrow),
      firstDate: tomorrow, 
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    bool isEdit = widget.event != null;

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
                forceElevated: true,
                shadowColor: const Color(0x0C683BFC),
                elevation: 8,
                title: Text(
                  isEdit ? 'Edit Event' : 'Create New Event',
                  style: const TextStyle(color: Color(0xFF13123A), fontSize: 16, fontWeight: FontWeight.w700),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF13123A)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Event Name"),
                        _buildTextField(_nameController, "Enter event name"),
                        const SizedBox(height: 20),

                        _buildLabel("Select Your Venue"),
                        _isLoadingVenues 
                          ? const Center(child: CircularProgressIndicator())
                          : _ownerVenues.isEmpty
                            ? const Text("You don't have any venues yet. Please create a venue first.", style: TextStyle(color: Colors.red, fontSize: 12))
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEBEBEB),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE0E0E6)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Venue>(
                                    value: _selectedVenue,
                                    isExpanded: true,
                                    hint: const Text("Select from your venues", style: TextStyle(color: Color(0xFFC7C7D1), fontSize: 14)),
                                    items: _ownerVenues.map((Venue venue) {
                                      return DropdownMenuItem<Venue>(
                                        value: venue,
                                        child: Text(venue.name, style: const TextStyle(fontSize: 14)),
                                      );
                                    }).toList(),
                                    onChanged: (Venue? newValue) {
                                      setState(() {
                                        _selectedVenue = newValue;
                                      });
                                    },
                                  ),
                                ),
                              ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Date"),
                                  InkWell(
                                    onTap: _pickDate,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEBEBEB),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE0E0E6)),
                                      ),
                                      child: Text(
                                        _selectedDate == null ? "Select Date" : "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
                                        style: TextStyle(color: _selectedDate == null ? const Color(0xFFC7C7D1) : Colors.black, fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Start Time"),
                                  InkWell(
                                    onTap: _pickTime,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEBEBEB),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE0E0E6)),
                                      ),
                                      child: Text(
                                        _selectedTime == null ? "Select Time" : "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}",
                                        style: TextStyle(color: _selectedTime == null ? const Color(0xFFC7C7D1) : Colors.black, fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        _buildLabel("Description"),
                        _buildTextField(_descriptionController, "Enter event description", maxLines: 3),
                        const SizedBox(height: 20),

                        _buildLabel("Image URL"),
                        _buildTextField(_thumbnailController, "Paste image URL here"),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 34),
              color: Colors.white,
              child: CustomButton(
                text: isEdit ? 'Update Event' : 'Create Event',
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _selectedDate != null && _selectedTime != null && _selectedVenue != null) {
                    
                    String formattedDate = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
                    String formattedTime = "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}";

                    Map<String, dynamic> body = {
                      "name": _nameController.text,
                      "description": _descriptionController.text,
                      "date": formattedDate,
                      "start_time": formattedTime,
                      "venue_id": _selectedVenue!.id.toString(),
                      "thumbnail": _thumbnailController.text,
                    };

                    String url = isEdit 
                        ? 'http://localhost:8000/event/update-flutter/${widget.event!.id}/'
                        : 'http://localhost:8000/event/create-flutter/';

                    try {
                      final response = await request.postJson(url, jsonEncode(body));

                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
                          Navigator.pop(context, true); 
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(response['message'] ?? "Error occurred"),
                            backgroundColor: Colors.red,
                          ));
                        }
                      }
                    } catch (e) {
                      debugPrint("Error submitting form: $e");
                    }
                  } else if (_selectedVenue == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a venue")));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
                  }
                },
                isFullWidth: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF101727), fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String placeholder, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFEBEBEB),
        hintText: placeholder,
        hintStyle: const TextStyle(color: Color(0xFFC7C7D1), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MyApp.darkSlate),
        ),
      ),
    );
  }
}
