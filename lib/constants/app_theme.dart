import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Colors.blue;
  static const Color accentColor = Colors.blueAccent;
  static const Color backgroundColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF37474F); // blueGrey[800]
  static const Color textSecondaryColor = Color(0xFF607D8B); // blueGrey[600]

  // Dark theme colors
  static const Color darkPrimaryColor = Color(0xFF1976D2); // darker blue
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkTextPrimaryColor = Colors.white;
  static const Color darkTextSecondaryColor = Colors.white70;

  // Light theme
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textTheme: GoogleFonts.latoTextTheme(),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
    ),
  );

  // Dark theme (can be implemented later)
  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: darkPrimaryColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: darkPrimaryColor,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: accentColor,
      unselectedItemColor: Colors.grey,
      backgroundColor: darkSurfaceColor,
    ),
    cardTheme: const CardTheme(
      color: darkSurfaceColor,
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: darkSurfaceColor,
    ),
  );

  // Text styles
  static TextStyle headingStyle({bool isDark = false}) =>
      GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: isDark ? darkTextPrimaryColor : textPrimaryColor,
        letterSpacing: 1.5,
      );

  static TextStyle subheadingStyle({bool isDark = false}) => GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: isDark ? darkTextSecondaryColor : textSecondaryColor,
        letterSpacing: 0.5,
      );
}
