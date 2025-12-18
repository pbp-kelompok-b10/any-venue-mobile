import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/account/widgets/header.dart';
import 'package:any_venue/account/models/profile.dart'; // Pastikan path model benar

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  // Fungsi untuk mengambil data dari Django
  Future<Profile> fetchProfile(CookieRequest request) async {
    // NOTE: Ganti URL sesuai device:
    // Android Emulator: http://10.0.2.2:8000/account/api/profile/
    // Chrome / iOS: http://localhost:8000/account/api/profile/
    final response = await request.get("http://localhost:8000/account/api/profile/page/");

    if (response['status'] == true) {
      // Parsing JSON ke Model Profile
      return Profile.fromJson(response['user_data']);
    } else {
      throw Exception("Gagal mengambil profil: ${response['message']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: MyApp.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header (Tetap muncul walau sedang loading)
            const Header(title: 'Profile'),

            // 2. Konten Profil dengan FutureBuilder
            Expanded(
              child: FutureBuilder<Profile>(
                future: fetchProfile(request),
                builder: (context, snapshot) {
                  // A. Tampilan saat Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: MyApp.darkSlate,
                      ),
                    );
                  }
                  
                  // B. Tampilan jika Error
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: MyApp.orange),
                          const SizedBox(height: 16),
                          Text(
                            "Gagal memuat profil.",
                            style: TextStyle(color: MyApp.gumetalSlate),
                          ),
                          Text(
                            snapshot.error.toString(), // Debugging info
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // C. Tampilan jika Data Kosong (null)
                  if (!snapshot.hasData) {
                    return const Center(child: Text("Tidak ada data profil."));
                  }

                  // D. Tampilan SUKSES (Data tersedia)
                  final userProfile = snapshot.data!;
                  
                  // Logic ambil huruf depan
                  String initial = userProfile.username.isNotEmpty 
                      ? userProfile.username[0].toUpperCase() 
                      : "?";

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 32),

                        // --- Avatar Container ---
                        Container(
                          width: 100,
                          height: 100,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment(1.00, 0.50),
                              end: Alignment(0.00, 0.50),
                              colors: [
                                MyApp.gumetalSlate,
                                MyApp.darkSlate,
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(360),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: MyApp.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // --- Nama & Role ---
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Nama Username
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  userProfile.username,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: MyApp.gumetalSlate,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    height: 1.50,
                                  ),
                                ),
                              ),

                              // Role
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  userProfile.role, // Tampilkan Role
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: MyApp.orange.withOpacity(0.8), // Sedikit diperjelas opacity-nya
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    height: 1.50,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}