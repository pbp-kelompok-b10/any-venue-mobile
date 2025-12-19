import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/account/widgets/header.dart';
import 'package:any_venue/account/widgets/profile_info.dart';
import 'package:any_venue/account/models/profile.dart'; 
import 'package:any_venue/widgets/components/button.dart';
import 'package:any_venue/widgets/toast.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  
  late Future<Profile> _profileFuture;
  String _selectedRole = "USER"; 
  
  // Flag untuk menandai apakah data sudah dimuat ke form
  bool _isInitialized = false; 
  bool _isSaving = false;

  // Variabel untuk menyimpan snapshot data awal
  String _originalUsername = "";
  String _originalRole = "";

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onFieldChanged);
    
    final request = Provider.of<CookieRequest>(context, listen: false);
    _profileFuture = fetchProfile(request);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onFieldChanged);
    _usernameController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    // Hanya panggil setState jika inisialisasi sudah selesai
    // untuk menghindari error 'setState during build'
    if (_isInitialized) {
      setState(() {}); 
    }
  }

  Future<Profile> fetchProfile(CookieRequest request) async {
    // Gunakan 10.0.2.2 untuk Emulator, localhost untuk Web
    final response = await request.get("https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/account/api/profile/");

    if (response['status'] == true) {
      return Profile.fromJson(response['user_data']);
    } else {
      throw Exception("Failed to fetch profile: ${response['message']}");
    }
  }

  bool get _hasChanges {
    return _usernameController.text != _originalUsername || _selectedRole != _originalRole;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: MyApp.white,
      body: SafeArea(
        child: Column(
          children: [
            const Header(title: 'Edit Profile'),
            Expanded(
              child: FutureBuilder<Profile>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: MyApp.darkSlate));
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: Text("No profile data available."));
                  }

                  // --- LOGIKA PENGISIAN DATA ---
                  // Hanya dijalankan SEKALI saat data pertama kali tiba
                  if (!_isInitialized) {
                    final profile = snapshot.data!;
                    
                    _usernameController.text = profile.username;
                    _selectedRole = (profile.role == "OWNER") ? "OWNER" : "USER";
                    
                    // Simpan data asli untuk pembanding dan TAMPILAN STATIC HEADER
                    _originalUsername = profile.username;
                    _originalRole = _selectedRole;
                    
                    _isInitialized = true; 
                  }

                  // --- DATA UNTUK HEADER (STATIC) ---
                  // Kita gunakan _originalUsername agar tidak berubah saat diketik
                  // Jika belum initialized, pakai data snapshot langsung
                  final staticUsername = _isInitialized ? _originalUsername : snapshot.data!.username;
                  final staticRole = _isInitialized ? _originalRole : snapshot.data!.role;

                  String initial = staticUsername.isNotEmpty 
                      ? staticUsername[0].toUpperCase() 
                      : "?";

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          
                          // --- PROFILE INFO (TETAP STATIC) ---
                          ProfileInfo(
                            initial: initial,
                            username: staticUsername, // Menggunakan nama asli
                            role: staticRole,         // Menggunakan role asli
                          ),

                          const SizedBox(height: 32),

                          _buildInputLabel("Username"),
                          const SizedBox(height: 8),
                          _buildCustomTextField(
                            controller: _usernameController,
                            hintText: "Enter your username",
                          ),

                          const SizedBox(height: 24),

                          _buildInputLabel("Role"),
                          const SizedBox(height: 8),
                          _buildRoleSelector(),

                          const SizedBox(height: 16),

                          _buildWarningMessage(),

                          const SizedBox(height: 40),

                          // --- SAVE BUTTON ---
                          // ... di dalam build() -> Column -> CustomButton
                            CustomButton(
                            text: "Save Changes",
                            isFullWidth: true,
                            isLoading: _isSaving,
                            color: !_hasChanges ? Colors.grey[400] : null,
                            gradientColors: !_hasChanges
                                ? [Colors.grey[400]!, Colors.grey[400]!]
                                : [MyApp.gumetalSlate, MyApp.darkSlate],
                            onPressed: () async {
                                // 1. Cek jika tidak ada perubahan
                                if (!_hasChanges) {
                                CustomToast.show(
                                    context,
                                    message: "No Changes Detected",
                                    subMessage: "You haven't changed your profile info.",
                                    isError: true, // Akan menggunakan warna Orange (MyApp.orange)
                                );
                                return;
                                }

                                if (_formKey.currentState!.validate()) {
                                setState(() => _isSaving = true);

                                try {
                                    final response = await request.post(
                                    "https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/account/api/profile/edit/",
                                    {
                                        'username': _usernameController.text,
                                        'role': _selectedRole,
                                    },
                                    );

                                    if (mounted) {
                                    setState(() => _isSaving = false);
                                    
                                    if (response != null && response['status'] == true) {
                                        // 2. SUKSES UPDATE
                                        CustomToast.show(
                                        context,
                                        message: "Profile Updated!",
                                        subMessage: "Your changes have been saved successfully.",
                                        isError: false, // Warna Dark Slate + Icon Check
                                        );
                                        
                                        Navigator.pop(context, true); // Kembali ke halaman sebelumnya
                                    } else {
                                        // 3. GAGAL DARI SERVER
                                        CustomToast.show(
                                        context,
                                        message: "Update Failed",
                                        subMessage: response['message'] ?? "Please try again later.",
                                        isError: true,
                                        );
                                    }
                                    }
                                } catch (e) {
                                    if (mounted) setState(() => _isSaving = false);
                                    // 4. ERROR KONEKSI / LAINNYA
                                    CustomToast.show(
                                    context,
                                    message: "An Error Occurred",
                                    subMessage: e.toString(),
                                    isError: true,
                                    );
                                }
                                }
                            },
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildWarningMessage() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 18, color: MyApp.orange),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Changing your role will permanently delete all data from your previous role.',
            style: TextStyle(
              color: MyApp.gumetalSlate,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF101727),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildCustomTextField({required TextEditingController controller, required String hintText}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: ShapeDecoration(
        color: const Color(0xFFF5F5F5),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE0E0E6)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFC7C7D1), fontSize: 14),
        ),
        style: const TextStyle(color: Color(0xFF101727), fontSize: 14),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: ShapeDecoration(
        color: const Color(0xFFF5F5F5),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE0E0E6)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          isExpanded: true,
          items: ["USER", "OWNER"].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value == "USER" ? "User" : "Owner"),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedRole = newValue!;
            });
          },
        ),
      ),
    );
  }
}