import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/widgets/components/avatar.dart';
import 'package:any_venue/account/widgets/header.dart';
import 'package:any_venue/account/models/profile.dart';
import 'package:any_venue/account/widgets/profile_info.dart';
import 'package:any_venue/account/screens/edit_profile.dart';
import 'package:any_venue/widgets/main_navigation.dart';
import 'package:any_venue/widgets/components/button.dart';
import 'package:any_venue/screens/welcome_screen.dart';
import 'package:any_venue/widgets/toast.dart'; 
import 'package:any_venue/widgets/components/app_bar.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Profile> fetchProfile(CookieRequest request) async {
    // Android Emulator: http://10.0.2.2:8000/account/api/profile/
    // Chrome / iOS: https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/account/api/profile/
    final response = await request.get(
      "https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/account/api/profile/",
    );

    if (response['status'] == true) {
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
      appBar : const CustomAppBar(title: 'Profile', showBackButton: false),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<Profile>(
                future: fetchProfile(request),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: MyApp.darkSlate),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: MyApp.orange),
                          const SizedBox(height: 16),
                          const Text("Failed to load profile.", style: TextStyle(color: MyApp.gumetalSlate)),
                          Text(snapshot.error.toString(),
                              style: const TextStyle(fontSize: 10, color: MyApp.gumetalSlate),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: Text("No profile data available.", style: TextStyle(color: MyApp.gumetalSlate)));
                  }

                  final userProfile = snapshot.data!;
                  String initial = userProfile.username.isNotEmpty 
                      ? userProfile.username[0].toUpperCase() 
                      : "?";

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 86),
                        ProfileInfo(
                          initial: initial,
                          username: userProfile.username,
                          role: userProfile.role,
                        ),

                        const SizedBox(height: 36),

                        // --- LIST TOMBOL MENU ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _buildMenuButton(
                                icon: Icons.edit,
                                label: 'Edit Profile',
                                backgroundColor: MyApp.deepWhite,
                                textColor: MyApp.gumetalSlate,
                                iconColor: MyApp.gumetalSlate,
                                hasTrailing: true,

                                onTap: () async {
                                  final oldRole = request.jsonData['role'];

                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const EditProfilePage()),
                                  );

                                  if (result == true) {
                                    if (!mounted) return;

                                    // Tampilkan loading sebentar
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => const Center(child: CircularProgressIndicator()),
                                    );

                                    try {
                                      final response = await request.get("https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/account/api/profile/");
                                      
                                      if (!mounted) return;
                                      Navigator.pop(context); // Tutup loading dialog

                                      if (response['status'] == true) {
                                        request.jsonData['username'] = response['user_data']['username'];
                                        request.jsonData['role'] = response['user_data']['role'];

                                        final newRole = response['user_data']['role'];

  
                                        if (oldRole != newRole) {
                                          int targetIndex = 4;
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(builder: (context) => MainNavigation(initialIndex: targetIndex)),
                                            (route) => false,
                                          );
                                        } 

                                        else {
                                          setState(() {
                                          });
                                        }
                                      }
                                    } catch (e) {
                                      if (mounted) Navigator.pop(context); // Tutup loading jika error
                                    }
                                  }
                                },
                              ),
                              _buildMenuButton(
                                icon: Icons.logout,
                                label: 'Logout',
                                backgroundColor: MyApp.deepWhite,
                                textColor: MyApp.gumetalSlate,
                                iconColor: MyApp.gumetalSlate,
                                hasTrailing: true,
                                onTap: () {
                                  _handleLogout(context);
                                },
                              ),
                              _buildMenuButton(
                                icon: Icons.cancel,
                                label: 'Delete Account',
                                backgroundColor: MyApp.orange,
                                textColor: MyApp.white,
                                iconColor: MyApp.white,
                                hasTrailing: false,
                                onTap: () {
                                  _showDeleteConfirmation(context);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
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

  // Widget Helper 
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required Color iconColor,
    required bool hasTrailing,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.transparent, 
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16), 
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: backgroundColor, 
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ),
                if (hasTrailing)
                  Icon(Icons.chevron_right, size: 16, color: iconColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          backgroundColor: MyApp.white,
          elevation: 10,
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MyApp.orange.withOpacity(0.1), 
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: MyApp.orange,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Account?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: MyApp.gumetalSlate,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to remove your account permanently? All your data will be lost forever.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: MyApp.darkSlate,
            ),
          ),
          actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                text: 'Cancel',
                isOutlined: false,
                gradientColors: [MyApp.gumetalSlate, MyApp.darkSlate],
                width: 130,
                onPressed: () => Navigator.of(context).pop(),
              ),

              const SizedBox(width: 12), 

              CustomButton(
                text: 'Delete',
                color: MyApp.orange,
                isOutlined: false,
                width: 130,
                onPressed: () async {
                  Navigator.of(context).pop(); 
                  await _performDeleteAccount(context); 
                },
              ),
            ],
          ),
          ],
        );
      },
    );
  }

  Future<void> _performDeleteAccount(BuildContext context) async {
    final request = Provider.of<CookieRequest>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await request.post(
        "https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/account/api/profile/delete/", 
        {} 
      );

      if (context.mounted) Navigator.pop(context);

      if (response['success'] == true) {
        if (context.mounted) {
          // --- TOAST SUKSES DELETE ---
          CustomToast.show(
            context,
            message: "Account Deleted",
            subMessage: "Your account has been permanently removed.",
            isError: false,
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()), 
            (route) => false,
          );
        }
      } else {
        if (context.mounted) {
          // --- TOAST GAGAL DELETE ---
          CustomToast.show(
            context,
            message: "Deletion Failed",
            subMessage: response['message'] ?? "Could not delete account.",
            isError: true,
          );
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      
      // --- TOAST ERROR EXCEPTION ---
      CustomToast.show(
        context,
        message: "Network Error",
        subMessage: e.toString(),
        isError: true,
      );
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final request = Provider.of<CookieRequest>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await request.logout("https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/auth/api/logout/"); 
      
      if (context.mounted) Navigator.pop(context);

      if (response['status'] == true) {
        if (context.mounted) {
          // --- TOAST SUKSES LOGOUT ---
          CustomToast.show(
            context,
            message: "See you soon!",
            subMessage: "You have successfully logged out.",
            isError: false,
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()), 
            (route) => false,
          );
        }
      } else {
        if (context.mounted) {
          // --- TOAST GAGAL LOGOUT ---
          CustomToast.show(
            context,
            message: "Logout Failed",
            subMessage: response['message'] ?? "Please try again.",
            isError: true,
          );
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      
      if (context.mounted) {
          // Tetap paksa keluar jika error, tapi kasih info
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()), 
            (route) => false,
          );
      }
    }
  }
}
