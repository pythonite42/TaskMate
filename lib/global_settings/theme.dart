import 'package:flutter/material.dart';

class AppTheme {
  // Greens (Material-ish: success/progress)
  static const Color _primaryGreen = Color(0xFF16A34A); // ~green-600
  static const Color _primaryGreenDark = Color(0xFF166534); // ~green-800
  static const Color _primaryGreenLight = Color(0xFF4ADE80); // ~green-400

  // Neutrals
  static const Color _lightSurface = Color(0xFFF8FAFC); // soft neutral
  static const Color _darkSurface = Color(0xFF1E1E1E);
  static const Color _darkBg = Color(0xFF121212);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: _primaryGreen,
    colorScheme: ColorScheme.light(
      primary: _primaryGreen,
      onPrimary: Colors.white,
      secondary: _primaryGreenLight, // subtle accents (chips, FAB, etc.)
      onSecondary: Colors.white,
      surface: _lightSurface,
      onSurface: Colors.black87,
      error: Color(0xFFDC2626), // red-600
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: _lightSurface,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      hintStyle: const TextStyle(color: Colors.black38),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryGreen,
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
      fillColor: WidgetStateProperty.all(_primaryGreen),
    ),
    dividerTheme: const DividerThemeData(thickness: 0.5, color: Colors.black38),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: _primaryGreenDark,
    colorScheme: ColorScheme.dark(
      primary: _primaryGreenLight, // brighter green reads well on dark
      onPrimary: Colors.white,
      secondary: _primaryGreen, // deeper accent to avoid neon glow
      onSecondary: Colors.white,
      surface: _darkSurface,
      onSurface: Colors.white70,
      error: Color(0xFFF87171), // red-400
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: _darkBg,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      hintStyle: const TextStyle(color: Colors.white38),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryGreenLight,
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
      color: _darkSurface,
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      fillColor: WidgetStateProperty.all(_primaryGreenLight),
    ),
    dividerTheme: const DividerThemeData(thickness: 0.5, color: Colors.white, space: 1),
  );
}
