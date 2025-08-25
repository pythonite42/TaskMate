import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primaryBlue = Color(0xFF1565C0); // strong blue
  static const Color _primaryBlueDark = Color(0xFF0D47A1); // darker blue
  static const Color _primaryBlueLight = Color(0xFF42A5F5); // lighter accent

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: _primaryBlue,
    colorScheme: ColorScheme.light(
      primary: _primaryBlue,
      onPrimary: Colors.white,
      secondary: _primaryBlueLight,
      onSecondary: Colors.white,
      surface: const Color(0xFFF6F9FC),
      onSurface: Colors.black87,
      error: Colors.red.shade700,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF6F9FC),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      hintStyle: const TextStyle(color: Colors.black38),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      fillColor: WidgetStateProperty.all(_primaryBlue),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: _primaryBlueDark,
    colorScheme: ColorScheme.dark(
      primary: _primaryBlueLight,
      onPrimary: Colors.white,
      secondary: _primaryBlue,
      onSecondary: Colors.white,
      surface: const Color(0xFF1E1E1E),
      onSurface: Colors.white70,
      //TODO remove: background: const Color(0xFF121212),
      error: Colors.red.shade400,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      hintStyle: const TextStyle(color: Colors.white38),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryBlueLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      color: const Color(0xFF1E1E1E),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      fillColor: WidgetStateProperty.all(_primaryBlueLight),
    ),
  );
}
