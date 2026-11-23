import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../state/auth_provider.dart';
import '../../state/chat_provider.dart';
import '../../state/connection_provider.dart';
import '../../state/notification_provider.dart';
import 'push_notification_service.dart';

final realtimeNotificationServiceProvider = Provider<RealtimeNotificationService>((ref) {
  final service = RealtimeNotificationService(ref);
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

class RealtimeNotificationService {
  final Ref _ref;
  RealtimeChannel? _notifChannel;
  RealtimeChannel? _reqChannel;
  RealtimeChannel? _msgChannel;
  RealtimeChannel? _memberChannel;
  RealtimeChannel? _convChannel;
  String? _subscribedUserId;

  RealtimeNotificationService(this._ref) {
    _init();
  }

  void _init() {
    _ref.listen(authProvider, (previous, next) {
      final user = next.value;
      if (user != null && user.uid != _subscribedUserId) {
        subscribeForUser(user.uid);
        PushNotificationService().syncDeviceToken(user.uid);
      } else if (user == null) {
        dispose();
      }
    }, fireImmediately: true);
  }

  void subscribeForUser(String userId) {
    dispose();
    _subscribedUserId = userId;

    final client = Supabase.instance.client;

    try {
      // 1. Listen for new notifications (likes, circle alerts, mentions, new messages)
      _notifChannel = client
          .channel('realtime:notifications:$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              debugPrint('Realtime notification received: ${payload.eventType}');
              HapticFeedback.lightImpact();
              _ref.invalidate(notificationsListProvider);
              _ref.invalidate(unreadNotificationsCountProvider);
              _ref.invalidate(conversationsProvider);
            },
          )
          .subscribe();

      // 2. Listen for incoming connection requests
      _reqChannel = client
          .channel('realtime:connections:$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'connection_requests',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'receiver_id',
              value: userId,
            ),
            callback: (payload) {
              debugPrint('Realtime connection request received: ${payload.eventType}');
              HapticFeedback.mediumImpact();
              _ref.invalidate(receivedRequestsProvider);
              _ref.invalidate(unreadNotificationsCountProvider);
            },
          )
          .subscribe();

      // 3. Listen for new conversation memberships (instantly detects new conversations created by another user)
      _memberChannel = client
          .channel('realtime:members:$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'conversation_members',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              debugPrint('Realtime conversation member received: ${payload.eventType}');
              HapticFeedback.selectionClick();
              _ref.invalidate(conversationsProvider);
            },
          )
          .subscribe();

      // 4. Listen for new direct messages
      _msgChannel = client
          .channel('realtime:messages:$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'messages',
            callback: (payload) {
              debugPrint('Realtime message event: ${payload.eventType}');
              HapticFeedback.selectionClick();
              _ref.invalidate(conversationsProvider);
            },
          )
          .subscribe();

      // 5. Listen for conversation updates (e.g. last_message_preview, last_message_at)
      _convChannel = client
          .channel('realtime:conversations:$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'conversations',
            callback: (payload) {
              debugPrint('Realtime conversation updated: ${payload.eventType}');
              _ref.invalidate(conversationsProvider);
            },
          )
          .subscribe();

      debugPrint('Supabase Realtime subscriptions established for user: $userId');
    } catch (e) {
      debugPrint('Notice: Realtime subscription setup: $e');
    }
  }

  void dispose() {
    try {
      _notifChannel?.unsubscribe();
      _reqChannel?.unsubscribe();
      _msgChannel?.unsubscribe();
      _memberChannel?.unsubscribe();
      _convChannel?.unsubscribe();
    } catch (_) {}
    _notifChannel = null;
    _reqChannel = null;
    _msgChannel = null;
    _memberChannel = null;
    _convChannel = null;
    _subscribedUserId = null;
  }
}
