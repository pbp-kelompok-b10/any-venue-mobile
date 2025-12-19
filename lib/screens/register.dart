import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:any_venue/screens/login.dart';
import 'package:any_venue/screens/welcome_screen.dart';
import 'package:any_venue/main.dart';
import 'package:any_venue/widgets/components/button.dart';
import 'package:any_venue/widgets/components/arrow_button.dart';
import 'package:any_venue/widgets/toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isOwner = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    const Color inputBg = Color(0xFFFAFAFA);
    const Color borderGray = Color(0xFFE0E0E6);

    return Scaffold(
      backgroundColor: Colors.white,
      // LayoutBuilder digunakan untuk mendapatkan tinggi layar yang tersedia
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            // ConstrainedBox memaksa konten minimal setinggi layar
            // Ini membuat konten berada di tengah jika layar besar,
            // tapi tetap bisa discroll jika keyboard muncul.
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Konten di tengah vertikal
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),

                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: ArrowButton(
                              isLeft: true,
                              size: 50.0,
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const WelcomeScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // --- HEADER ---
                        Text(
                          'Create new\naccount',
                          style: GoogleFonts.nunitoSans(
                            color: MyApp.gumetalSlate,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // --- SUB HEADER ---
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Already have an account? ',
                                style: GoogleFonts.nunitoSans(
                                  color: MyApp.gumetalSlate,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: 'Sign In',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                    );
                                  },
                                style: GoogleFonts.nunitoSans(
                                  color: MyApp.orange,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24), // Jarak ke form diperkecil
                        // --- INPUTS ---
                        // Menggunakan Column untuk input agar coding lebih rapi & compact
                        _buildInputGroup(
                          label: "Username",
                          controller: _usernameController,
                          hint: "Enter your username",
                          inputBg: inputBg,
                          borderGray: borderGray,
                        ),
                        const SizedBox(
                          height: 12,
                        ), // Jarak antar input Rapat (Compact)

                        _buildInputGroup(
                          label: "Password",
                          controller: _passwordController,
                          hint: "Enter your password",
                          inputBg: inputBg,
                          borderGray: borderGray,
                          isPassword: true,
                        ),
                        const SizedBox(height: 12),

                        _buildInputGroup(
                          label: "Confirm Password",
                          controller: _confirmPasswordController,
                          hint: "Re-enter your password",
                          inputBg: inputBg,
                          borderGray: borderGray,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Required";
                            if (value != _passwordController.text)
                              return "Mismatch";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // --- OWNER PROMO TEXT ---
                        Text(
                          'Got a place you want to share with others?\nBecome an Owner and start adding your own venue!',
                          style: GoogleFonts.nunitoSans(
                            color: MyApp.gumetalSlate,
                            fontSize: 13, // Font size disesuaikan
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),

                        // --- CHECKBOX OWNER ---
                        // Menggunakan Transform untuk menghilangkan default padding checkbox
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: isOwner,
                                activeColor: MyApp.darkSlate,
                                side: const BorderSide(
                                  color: borderGray,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    isOwner = value ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'I am an Owner',
                              style: GoogleFonts.nunitoSans(
                                color: MyApp.gumetalSlate,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // --- BUTTON REFACTORED ---
                        CustomButton(
                          text: 'Sign Up',
                          isFullWidth: true,
                          isLoading:
                              _isLoading, // Otomatis handle loading spinner
                          // Masukkan dua warna gradasi sesuai desainmu
                          gradientColors: const [
                            MyApp.gumetalSlate,
                            MyApp.darkSlate,
                          ],
                          onPressed: () async {
                            // Validasi Form
                            if (_formKey.currentState!.validate()) {
                              setState(
                                () => _isLoading = true,
                              ); // Set loading state

                              String username = _usernameController.text;
                              String password1 = _passwordController.text;
                              String password2 =
                                  _confirmPasswordController.text;

                              // --- REQUEST API ---
                              final response = await request.postJson(
                                "https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/auth/api/register/",
                                jsonEncode({
                                  "username": username,
                                  "password1": password1,
                                  "password2": password2,
                                  "is_owner": isOwner.toString(),
                                }),
                              );

                              setState(
                                () => _isLoading = false,
                              ); // Stop loading state

                              // --- HANDLE RESPONSE ---
                              if (context.mounted) {
                                bool isSuccess = response["success"] == true;
                                final String title = isSuccess
                                    ? "Registration Successful"
                                    : "Registration Failed";
                                final String detail = isSuccess
                                    ? "Your account has been created!" // Pakai variable 'username' yang sudah ada
                                    : (response["error"] ??
                                          "An error occurred.");

                                CustomToast.show(
                                  context,
                                  message: title,
                                  subMessage: detail,
                                  isError: !isSuccess,
                                );

                                if (isSuccess) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 20), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET BUILDER UNTUK MERAPIKAN KODE ---
  Widget _buildInputGroup({
    required String label,
    required TextEditingController controller,
    required String hint,
    required Color inputBg,
    required Color borderGray,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunitoSans(
            color: const Color(0xFF13123A),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: inputBg,
            hintText: hint,
            hintStyle: GoogleFonts.nunitoSans(
              color: const Color(0xFFC7C7D1),
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ), // Padding dalam input diperkecil
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderGray, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: MyApp.darkSlate, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: MyApp.orange, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: MyApp.orange, width: 1.5),
            ),
          ),
          validator:
              validator ??
              (value) {
                if (value == null || value.isEmpty)
                  return "$label cannot be empty";
                return null;
              },
        ),
      ],
    );
  }
}
