import 'package:any_venue/screens/welcome_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:any_venue/screens/register.dart';
import 'package:any_venue/main.dart'; // Import main.dart untuk akses warna MyApp
import 'package:any_venue/widgets/components/button.dart';
import 'package:any_venue/widgets/components/arrow_button.dart';
import 'package:any_venue/widgets/toast.dart';
import 'package:any_venue/widgets/main_navigation.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(secondary: Colors.blueAccent[400]),
        textTheme: GoogleFonts.nunitoSansTextTheme(),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    const Color inputBg = Color(0xFFFAFAFA);
    const Color borderGray = Color(0xFFE0E0E6);

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                        'Sign in to\nyour account',
                        style: GoogleFonts.nunitoSans(
                          color: MyApp.gumetalSlate,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // --- SUB HEADER (Link to Register) ---
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Don\'t have an account? ',
                              style: GoogleFonts.nunitoSans(
                                color: MyApp.gumetalSlate,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: 'Sign Up',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPage(),
                                    ),
                                  );
                                },
                              style: GoogleFonts.nunitoSans(
                                color: MyApp
                                    .orange, // Menggunakan warna dari main.dart
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),

                      // --- INPUT: USERNAME ---
                      _buildLabel("Username"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _usernameController,
                        decoration: _inputDecoration(
                          hint: "Enter your username",
                          bgColor: inputBg,
                          borderColor: borderGray,
                          activeColor: MyApp.darkSlate,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- INPUT: PASSWORD ---
                      _buildLabel("Password"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration(
                          hint: "Enter your password",
                          bgColor: inputBg,
                          borderColor: borderGray,
                          activeColor: MyApp.darkSlate,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFFC7C7D1),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // BUTTON SIGN IN
                      CustomButton(
                        text: 'Sign In',
                        isFullWidth: true,
                        isLoading:
                            _isLoading, // Otomatis mengatur spinner & disable klik
                        gradientColors: const [
                          MyApp.gumetalSlate,
                          MyApp.darkSlate,
                        ], // Warna Gradasi
                        onPressed: () async {
                          // 1. Mulai Loading
                          setState(() {
                            _isLoading = true;
                          });

                          String username = _usernameController.text;
                          String password = _passwordController.text;

                          // 2. Request API
                          // Ganti URL sesuai environment (localhost / 10.0.2.2)
                          final response = await request.login(
                            "https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/auth/api/login/",
                            {'username': username, 'password': password},
                          );

                          // 3. Selesai Loading
                          setState(() {
                            _isLoading = false;
                          });

                          // 4. Handle Response
                          if (request.loggedIn) {
                            // --- SUCCESS ---
                            String message = response['message'];
                            String uname = response['username'];

                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainNavigation(),
                                ),
                              );
                              CustomToast.show(
                                context,
                                message: "$message",
                                subMessage: "Welcome back, $uname.",
                                isError: false,
                              );
                            }
                          } else {
                            // --- FAILED ---
                            if (context.mounted) {
                              CustomToast.show(
                                context,
                                message: "Login Failed",
                                subMessage:
                                    response['message'] ?? 'Unknown error',
                                isError: true, // Warna jadi Orange
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- HELPER: Label Text ---
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.nunitoSans(
        color: const Color(0xFF13123A),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // --- HELPER: Input Decoration Style ---
  InputDecoration _inputDecoration({
    required String hint,
    required Color bgColor,
    required Color borderColor,
    required Color activeColor,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: bgColor,
      hintText: hint,
      hintStyle: GoogleFonts.nunitoSans(
        color: const Color(0xFFC7C7D1),
        fontSize: 14,
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: activeColor, width: 1.5),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
