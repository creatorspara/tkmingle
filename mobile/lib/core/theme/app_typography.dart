import 'package:flutter/material.dart';


/// Official TKMingle Typography System using Sora
class AppTypography {
  // Display Headings: Sora Bold (w700)
  static TextStyle displayLarge(Color color) => TextStyle(fontFamily: 'Sora', 
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: -0.5,
  );

  static TextStyle displayMedium(Color color) => TextStyle(fontFamily: 'Sora', 
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: -0.3,
  );

  // Page Headings: Sora SemiBold (w600)
  static TextStyle headlineLarge(Color color) => TextStyle(fontFamily: 'Sora', 
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: -0.2,
  );

  static TextStyle headlineMedium(Color color) => TextStyle(fontFamily: 'Sora', 
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: color,
  );

  // Section Headings: Sora Medium (w500)
  static TextStyle titleLarge(Color color) => TextStyle(fontFamily: 'Sora', 
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle titleMedium(Color color) => TextStyle(fontFamily: 'Sora', 
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: color,
  );

  // Body Text: Sora Regular (w400)
  static TextStyle bodyLarge(Color color) => TextStyle(fontFamily: 'Sora', 
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.45,
  );

  static TextStyle bodyMedium(Color color) => TextStyle(fontFamily: 'Sora', 
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.4,
  );

  // Buttons: Sora SemiBold (w600)
  static TextStyle button(Color color) => TextStyle(fontFamily: 'Sora', 
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: 0.2,
  );

  static TextStyle labelLarge(Color color) => TextStyle(fontFamily: 'Sora', 
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: 0.1,
  );

  // Metadata: Sora Regular (w400)
  static TextStyle metadata(Color color) => TextStyle(fontFamily: 'Sora', 
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: color,
    letterSpacing: 0.1,
  );

  static TextStyle labelSmall(Color color) => TextStyle(fontFamily: 'Sora', 
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: color,
  );
}
