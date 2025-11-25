import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:any_venue/screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  static const Color LightCyan = Color(0xFFE0FBFC); 
  static const Color PaleCerulean = Color(0xFF98C1D9);
  static const Color Sunrise = Color(0xFFEE6C4D);
  static const Color Orange = Color(0xFFE9631A); 
  static const Color LightNavy = Color(0xFF3D5A80);
  static const Color DarkSlate = Color(0xFF315672);
  static const Color GumetalStale = Color(0xFF293241); 
  static const Color FlashWhite = Color(0xFFEFEFEF);

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
          useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
          .copyWith(secondary: Colors.blueAccent[400]),
        ),
        home: const LoginPage(),
      ),
    );
  }
}