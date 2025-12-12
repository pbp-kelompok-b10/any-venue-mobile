import 'package:any_venue/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color white = Color(0xFFFFFFFF);
  static const Color orange = Color(0xFFE9631A);
  static const Color darkSlate = Color(0xFF315672);
  static const Color gumetalSlate = Color(0xFF293241);
  static const Color deepWhite = Color(0xEBEBEB);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AnyVenue',
        theme: ThemeData(
          useMaterial3: false,
          scaffoldBackgroundColor: white,
          colorScheme: ColorScheme(
            brightness: Brightness.light,
            primary: darkSlate,
            onPrimary: white,
            secondary: orange,
            onSecondary: white,
            surface: white,
            onSurface: gumetalSlate,
            error: orange,
            onError: white,
          ),
          textTheme: GoogleFonts.nunitoSansTextTheme(),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
