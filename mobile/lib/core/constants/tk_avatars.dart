import 'package:flutter/material.dart';

class TkAvatar {
  final String id;
  final String name;
  final String category;
  final Color accentColor;
  final String assetPath;

  const TkAvatar({
    required this.id,
    required this.name,
    required this.category,
    required this.accentColor,
    required this.assetPath,
  });
}

class TkAvatars {
  static const List<TkAvatar> all = [
    TkAvatar(
      id: 'tk_avatar_01',
      name: 'Cyber Techie',
      category: 'Tech & Code',
      accentColor: Color(0xFF50D6C2),
      assetPath: 'assets/avatars/tk_avatar_01.png',
    ),
    TkAvatar(
      id: 'tk_avatar_02',
      name: 'Campus Coder',
      category: 'Tech & Code',
      accentColor: Color(0xFF8875FF),
      assetPath: 'assets/avatars/tk_avatar_02.png',
    ),
    TkAvatar(
      id: 'tk_avatar_03',
      name: 'Creative Artist',
      category: 'Arts & Design',
      accentColor: Color(0xFFFF6584),
      assetPath: 'assets/avatars/tk_avatar_03.png',
    ),
    TkAvatar(
      id: 'tk_avatar_04',
      name: 'Robotics Engineer',
      category: 'Engineering',
      accentColor: Color(0xFFFFB84D),
      assetPath: 'assets/avatars/tk_avatar_04.png',
    ),
    TkAvatar(
      id: 'tk_avatar_05',
      name: 'Campus Scholar',
      category: 'Campus Life',
      accentColor: Color(0xFFB9A9FF),
      assetPath: 'assets/avatars/tk_avatar_05.png',
    ),
    TkAvatar(
      id: 'tk_avatar_06',
      name: 'Space Explorer',
      category: 'Science & Maker',
      accentColor: Color(0xFF50D6C2),
      assetPath: 'assets/avatars/tk_avatar_06.png',
    ),
    TkAvatar(
      id: 'tk_avatar_07',
      name: 'Music Producer',
      category: 'Arts & Design',
      accentColor: Color(0xFFEC4899),
      assetPath: 'assets/avatars/tk_avatar_07.png',
    ),
    TkAvatar(
      id: 'tk_avatar_08',
      name: 'Athletic Runner',
      category: 'Campus Life',
      accentColor: Color(0xFF10B981),
      assetPath: 'assets/avatars/tk_avatar_08.png',
    ),
    TkAvatar(
      id: 'tk_avatar_09',
      name: 'Design Architect',
      category: 'Arts & Design',
      accentColor: Color(0xFF38BDF8),
      assetPath: 'assets/avatars/tk_avatar_09.png',
    ),
    TkAvatar(
      id: 'tk_avatar_10',
      name: 'AI Innovator',
      category: 'Tech & Code',
      accentColor: Color(0xFF8875FF),
      assetPath: 'assets/avatars/tk_avatar_10.png',
    ),
    TkAvatar(
      id: 'tk_avatar_11',
      name: 'Eco Pioneer',
      category: 'Science & Maker',
      accentColor: Color(0xFF4ADE80),
      assetPath: 'assets/avatars/tk_avatar_11.png',
    ),
    TkAvatar(
      id: 'tk_avatar_12',
      name: 'Debate Champion',
      category: 'Campus Life',
      accentColor: Color(0xFFF59E0B),
      assetPath: 'assets/avatars/tk_avatar_12.png',
    ),
    TkAvatar(
      id: 'tk_avatar_13',
      name: 'Mechanical Maker',
      category: 'Engineering',
      accentColor: Color(0xFFF97316),
      assetPath: 'assets/avatars/tk_avatar_13.png',
    ),
    TkAvatar(
      id: 'tk_avatar_14',
      name: 'Literature Scribe',
      category: 'Arts & Design',
      accentColor: Color(0xFFC084FC),
      assetPath: 'assets/avatars/tk_avatar_14.png',
    ),
    TkAvatar(
      id: 'tk_avatar_15',
      name: 'Photographer',
      category: 'Arts & Design',
      accentColor: Color(0xFF06B6D4),
      assetPath: 'assets/avatars/tk_avatar_15.png',
    ),
    TkAvatar(
      id: 'tk_avatar_16',
      name: 'Data Scientist',
      category: 'Tech & Code',
      accentColor: Color(0xFF3B82F6),
      assetPath: 'assets/avatars/tk_avatar_16.png',
    ),
    TkAvatar(
      id: 'tk_avatar_17',
      name: 'Quantum Physicist',
      category: 'Science & Maker',
      accentColor: Color(0xFFA855F7),
      assetPath: 'assets/avatars/tk_avatar_17.png',
    ),
    TkAvatar(
      id: 'tk_avatar_18',
      name: 'Game Developer',
      category: 'Tech & Code',
      accentColor: Color(0xFFF43F5E),
      assetPath: 'assets/avatars/tk_avatar_18.png',
    ),
    TkAvatar(
      id: 'tk_avatar_19',
      name: 'Campus Leader',
      category: 'Campus Life',
      accentColor: Color(0xFFEAB308),
      assetPath: 'assets/avatars/tk_avatar_19.png',
    ),
    TkAvatar(
      id: 'tk_avatar_20',
      name: 'Social Explorer',
      category: 'Campus Life',
      accentColor: Color(0xFF8875FF),
      assetPath: 'assets/avatars/tk_avatar_20.png',
    ),
    TkAvatar(
      id: 'tk_avatar_21',
      name: 'Startup Founder',
      category: 'Campus Life',
      accentColor: Color(0xFF14B8A6),
      assetPath: 'assets/avatars/tk_avatar_21.png',
    ),
    TkAvatar(
      id: 'tk_avatar_22',
      name: 'Circuit Hacker',
      category: 'Tech & Code',
      accentColor: Color(0xFF22C55E),
      assetPath: 'assets/avatars/tk_avatar_22.png',
    ),
    TkAvatar(
      id: 'tk_avatar_23',
      name: 'Astronomy Stargazer',
      category: 'Science & Maker',
      accentColor: Color(0xFF818CF8),
      assetPath: 'assets/avatars/tk_avatar_23.png',
    ),
    TkAvatar(
      id: 'tk_avatar_24',
      name: 'TKM Pioneer',
      category: 'Campus Life',
      accentColor: Color(0xFF50D6C2),
      assetPath: 'assets/avatars/tk_avatar_24.png',
    ),
  ];

  static final Map<String, TkAvatar> _byId = {
    for (var a in all) a.id: a,
  };

  static TkAvatar? getById(String? id) {
    if (id == null) return null;
    final clean = id.startsWith('preset:') ? id.replaceFirst('preset:', '') : id;
    return _byId[clean];
  }

  static bool isPreset(String? value) {
    if (value == null || value.isEmpty) return false;
    final clean = value.startsWith('preset:') ? value.replaceFirst('preset:', '') : value;
    return _byId.containsKey(clean);
  }

  static String getInitials(String string) {
    final clean = string.trim();
    if (clean.isEmpty) return '?';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean.substring(0, clean.length >= 2 ? 2 : 1).toUpperCase();
  }

  static const List<List<Color>> brandGradients = [
    [Color(0xFF8875FF), Color(0xFF50D6C2)], // TKM Purple to Teal
    [Color(0xFF6366F1), Color(0xFFB9A9FF)], // Indigo to Lavender
    [Color(0xFFEC4899), Color(0xFF8875FF)], // Pink to Purple
    [Color(0xFF10B981), Color(0xFF50D6C2)], // Emerald to Teal
    [Color(0xFFF59E0B), Color(0xFFEC4899)], // Amber to Pink
    [Color(0xFF06B6D4), Color(0xFF3B82F6)], // Cyan to Blue
    [Color(0xFF8B5CF6), Color(0xFFD946EF)], // Violet to Fuchsia
    [Color(0xFF14B8A6), Color(0xFF6366F1)], // Teal to Indigo
  ];

  static List<Color> getDeterministicGradient(String seed) {
    if (seed.isEmpty) return brandGradients[0];
    int hash = 0;
    for (int i = 0; i < seed.length; i++) {
      hash = (hash * 31 + seed.codeUnitAt(i)) & 0xFFFFFFF;
    }
    return brandGradients[hash % brandGradients.length];
  }
}
