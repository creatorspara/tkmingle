import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint("Handling a background FCM message: ${message.messageId}");
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  static const String channelId = 'tkmingle_alerts';
  static const String channelName = 'TKMingle Campus Alerts';
  static const String channelDescription = 'Connection requests, messages, and campus social updates';

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Currently active conversation ID (suppresses banners when viewing the chat)
  static String? activeConversationId;

  /// High importance notification channel for WhatsApp-style Heads-Up pop-up banners
  static const AndroidNotificationChannel _highImportanceChannel = AndroidNotificationChannel(
    channelId,
    channelName,
    description: channelDescription,
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  /// Initializes Firebase, notification channels, and sets up message listeners
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 1. Initialize local notifications with app icon
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint("Notification tapped with payload: ${response.payload}");
        },
      );

      // 2. Create the Android High-Importance channel
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(_highImportanceChannel);
      }

      // 3. Request permissions (especially required on Android 13+)
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('User notification permission status: ${settings.authorizationStatus}');

      // Enable heads-up foreground notification presentation
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 4. Handle foreground notifications (show heads-up banner)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground: ${message.messageId}');

        final currentUserId = Supabase.instance.client.auth.currentUser?.id;
        final senderId = message.data['sender_id'] ?? message.data['reference_id'];
        final type = message.data['type'];

        // 1. Suppress notification if current user is the sender of this message/alert
        if (currentUserId != null && senderId != null && currentUserId == senderId) {
          debugPrint('Suppressing popup for self-sent event');
          return;
        }

        // 2. Suppress notification if user is currently looking at this active conversation
        if (type == 'new_message' && activeConversationId != null) {
          final convId = message.data['conversation_id'] ?? message.data['reference_id'];
          if (convId == activeConversationId) {
            debugPrint('Suppressing in-chat popup for active conversation $activeConversationId');
            return;
          }
        }

        final notification = message.notification;
        if (notification != null) {
          _localNotifications.show(
            notification.hashCode,
            notification.title ?? 'TKMingle Alert',
            notification.body ?? '',
            NotificationDetails(
              android: AndroidNotificationDetails(
                _highImportanceChannel.id,
                _highImportanceChannel.name,
                channelDescription: _highImportanceChannel.description,
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
                playSound: true,
                enableVibration: true,
                visibility: NotificationVisibility.public,
              ),
            ),
            payload: message.data['reference_id'] ?? '',
          );
        }
      });
    } catch (e) {
      debugPrint("PushNotificationService initialization error: $e");
    }
  }

  /// Registers the device's FCM token in Supabase `public.device_tokens`
  Future<void> syncDeviceToken(String userId) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint("Obtained FCM device token: ${token.substring(0, 15)}...");

        final supabase = Supabase.instance.client;

        // Clear any previous user registered to this same physical phone token
        try {
          await supabase.from('device_tokens').delete().eq('device_token', token);
        } catch (_) {}

        await supabase.from('device_tokens').upsert(
          {
            'user_id': userId,
            'device_token': token,
            'platform': Platform.isAndroid ? 'android' : 'ios',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          },
          onConflict: 'user_id,platform',
        );
        debugPrint("Successfully synced device token with Supabase for user $userId");
      }

      // Listen for token refreshes
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        try {
          final supabase = Supabase.instance.client;
          try {
            await supabase.from('device_tokens').delete().eq('device_token', newToken);
          } catch (_) {}
          await supabase.from('device_tokens').upsert(
            {
              'user_id': userId,
              'device_token': newToken,
              'platform': Platform.isAndroid ? 'android' : 'ios',
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            },
            onConflict: 'user_id,platform',
          );
        } catch (_) {}
      });
    } catch (e) {
      debugPrint("Failed to sync device token with Supabase: $e");
    }
  }

  /// Removes the device token when user logs out
  Future<void> clearDeviceToken(String userId) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      final supabase = Supabase.instance.client;
      if (token != null) {
        await supabase.from('device_tokens').delete().eq('device_token', token);
      } else {
        await supabase.from('device_tokens').delete().eq('user_id', userId);
      }
    } catch (_) {}
  }
}
