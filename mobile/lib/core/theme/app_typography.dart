import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Official TKMingle Typography System using Sora
class AppTypography {
  // Display Headings: Sora Bold (w700)
  static TextStyle displayLarge(Color color) => GoogleFonts.sora(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: -0.5,
  );

  static TextStyle displayMedium(Color color) => GoogleFonts.sora(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: -0.3,
  );

  // Page Headings: Sora SemiBold (w600)
  static TextStyle headlineLarge(Color color) => GoogleFonts.sora(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: -0.2,
  );

  static TextStyle headlineMedium(Color color) => GoogleFonts.sora(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: color,
  );

  // Section Headings: Sora Medium (w500)
  static TextStyle titleLarge(Color color) => GoogleFonts.sora(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle titleMedium(Color color) => GoogleFonts.sora(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: color,
  );

  // Body Text: Sora Regular (w400)
  static TextStyle bodyLarge(Color color) => GoogleFonts.sora(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.45,
  );

  static TextStyle bodyMedium(Color color) => GoogleFonts.sora(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.4,
  );

  // Buttons: Sora SemiBold (w600)
  static TextStyle button(Color color) => GoogleFonts.sora(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: 0.2,
  );

  static TextStyle labelLarge(Color color) => GoogleFonts.sora(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: 0.1,
  );

  // Metadata: Sora Regular (w400)
  static TextStyle metadata(Color color) => GoogleFonts.sora(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: color,
    letterSpacing: 0.1,
  );

  static TextStyle labelSmall(Color color) => GoogleFonts.sora(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: color,
  );
}
