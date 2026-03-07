import 'package:flutter/material.dart';

class LanaTheme {
  static const Color darkBackground = Color(0xFF101010);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color emeraldGreenDarker = Color(0xFF047857);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color surfaceColor = Color(0xFF1E1E1E);
  static const Color textColor = Color(0xFFF3F4F6);
  static const Color textMuted = Color(0xFF9CA3AF);

  /// Premium serif style for "LanaYa" brand text across the app.
  static const TextStyle brandTitle = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
    letterSpacing: 1.2,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: emeraldGreen,
      colorScheme: const ColorScheme.dark(
        primary: emeraldGreen,
        secondary: goldAccent,
        surface: surfaceColor,
        background: darkBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: emeraldGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      fontFamily: 'Inter', // We can use google_fonts but defining default fallback
    );
  }
}
