import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color ink = Color(0xFF272B45);
  static const Color primary = Color(0xFF6875D8);
  static const Color softAccent = Color(0xFFE7E9FF);
  static const Color favorite = Color(0xFFE34D68);
  static const Color canvas = Color(0xFFF7F8FF);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF9FAFF), Color(0xFFE9EDFF)],
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: canvas,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: ink,
      centerTitle: false,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE3E7F5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color(0xFFFCFCFF),
      indicatorColor: softAccent,
    ),
    chipTheme: const ChipThemeData(
      selectedColor: softAccent,
      side: BorderSide(color: Color(0xFFE3E7F5)),
    ),
  );
}
