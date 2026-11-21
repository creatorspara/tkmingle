class AppConstants {
  static const String appName = 'TKMingle';
  static const String appTagline = 'Your campus. Your people. Your connections.';
  static const String collegeName = 'TKM College of Engineering';
  static const String collegeLocation = 'Kollam, Kerala, India';
  static const String collegeShort = 'TKMCE';

  // Storage Keys
  static const String prefsThemeKey = 'theme_mode';
  static const String prefsAuthUserKey = 'auth_user';
  static const String prefsDiscoverabilityKey = 'discoverability_enabled';

  // Limits
  static const int maxBioLength = 250;
  static const int maxInterestsCount = 10;
  static const int maxPromptsCount = 4;
  static const int defaultDailyRequestLimit = 15;

  // Supabase Unified Backend (Configured for TKMingle)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://mwwjuibehscukzueykjc.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
