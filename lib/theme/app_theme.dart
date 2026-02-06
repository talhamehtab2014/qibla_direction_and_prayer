import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFF2E7D32);
  static const Color secondaryLight = Color(0xFF66BB6A);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF66BB6A);
  static const Color secondaryDark = Color(0xFF81C784);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Light Theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryLight,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: primaryLight,
      secondary: secondaryLight,
      surface: surfaceLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryLight,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    ),
    iconTheme: const IconThemeData(color: primaryLight),
    textTheme: GoogleFonts.poppinsTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: textPrimaryLight,
        ),
        displayMedium: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: textPrimaryLight,
        ),
        bodyLarge: TextStyle(fontSize: 16.sp, color: textPrimaryLight),
        bodyMedium: TextStyle(fontSize: 14.sp, color: textSecondaryLight),
      ),
    ),
  );

  // Dark Theme
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryDark,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      secondary: secondaryDark,
      surface: surfaceDark,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: textPrimaryDark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: textPrimaryDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    ),
    iconTheme: const IconThemeData(color: primaryDark),
    textTheme: GoogleFonts.poppinsTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: textPrimaryDark,
        ),
        displayMedium: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: textPrimaryDark,
        ),
        bodyLarge: TextStyle(fontSize: 16.sp, color: textPrimaryDark),
        bodyMedium: TextStyle(fontSize: 14.sp, color: textSecondaryDark),
      ),
    ),
  );
}
