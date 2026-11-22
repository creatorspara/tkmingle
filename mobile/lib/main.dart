import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/services/push_notification_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'state/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase backend if configured
  if (AppConstants.isSupabaseConfigured) {
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase initialization notice: $e');
    }
  }

  // Initialize Firebase and WhatsApp-style high-priority Heads-Up notification channel
  try {
    await PushNotificationService().initialize();
  } catch (e) {
    debugPrint('Push notifications initialization notice: $e');
  }

  // Set immersive status bar styling matching TKMingle dark navy brand
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.deepNavy,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: TKMingleApp(),
    ),
  );
}

class TKMingleApp extends ConsumerWidget {
  const TKMingleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
