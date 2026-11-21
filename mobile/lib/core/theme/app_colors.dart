import 'package:flutter/material.dart';

/// Official TKMingle Brand Color System
/// Directly mapped from the official TKMingle Brand Board
class AppColors {
  // Primary Brand Colors
  static const Color deepNavy = Color(0xFF0A1026);
  static const Color tkmPurple = Color(0xFF8875FF);
  static const Color lavender = Color(0xFFB9A9FF);
  static const Color accentTeal = Color(0xFF50D6C2);
  static const Color primaryText = Color(0xFFF6F5FF);

  // Supporting Dark Theme Colors (Default)
  static const Color darkBackground = Color(0xFF0A1026);
  static const Color secondaryBackground = Color(0xFF141A32);
  static const Color cardBackground = Color(0xFF191E35);
  static const Color darkSurface = Color(0xFF141A32);
  static const Color darkCard = Color(0xFF191E35);
  static const Color darkElevated = Color(0xFF1E2648);
  static const Color border = Color(0xFF303451);
  static const Color darkBorder = Color(0xFF303451);

  static const Color mutedText = Color(0xFFA5A9BC);
  static const Color darkTextPrimary = Color(0xFFF6F5FF);
  static const Color darkTextSecondary = Color(0xFFA5A9BC);
  static const Color darkTextMuted = Color(0xFF6C7393);

  // Supporting Light Theme Colors
  static const Color lightBackground = Color(0xFFF8F9FD);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFF0F2FA);
  static const Color lightBorder = Color(0xFFDFE3F0);

  static const Color lightTextPrimary = Color(0xFF0A1026);
  static const Color lightTextSecondary = Color(0xFF4C5370);
  static const Color lightTextMuted = Color(0xFF7D85A0);

  // Functional & Status Colors
  static const Color primaryAccent = Color(0xFF8875FF); // TKM Purple
  static const Color secondaryAccent = Color(0xFFB9A9FF); // Lavender
  static const Color highlight = Color(0xFF50D6C2); // Accent Teal
  static const Color highlightWarm = Color(0xFFFF6B81); // Brand Alert / Warm Rose
  static const Color success = Color(0xFF50D6C2);
  static const Color warning = Color(0xFFFFB236);
  static const Color error = Color(0xFFFF6B81);
  static const Color info = Color(0xFF6C9EFF);

  // Brand Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8875FF), Color(0xFFB9A9FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleToDarkGradient = LinearGradient(
    colors: [Color(0xFF8875FF), Color(0xFF6C5CE7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bannerGradient = LinearGradient(
    colors: [Color(0xFF141A32), Color(0xFF0A1026)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardDarkGradient = LinearGradient(
    colors: [Color(0xFF191E35), Color(0xFF141A32)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient glowGradient = RadialGradient(
    colors: [Color(0x338875FF), Colors.transparent],
    radius: 0.8,
  );
}
