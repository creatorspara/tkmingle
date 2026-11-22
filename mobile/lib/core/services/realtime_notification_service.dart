import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../state/auth_provider.dart';
import '../../state/chat_provider.dart';
import '../../state/connection_provider.dart';
import '../../state/notification_provider.dart';

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
  String? _subscribedUserId;

  RealtimeNotificationService(this._ref) {
    _init();
  }

  void _init() {
    _ref.listen(authProvider, (previous, next) {
      final user = next.value;
      if (user != null && user.uid != _subscribedUserId) {
        subscribeForUser(user.uid);
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
      // 1. Listen for new notifications (likes, circle alerts, mentions)
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

      // 3. Listen for new incoming direct messages
      _msgChannel = client
          .channel('realtime:messages:$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'messages',
            callback: (payload) {
              final newRow = payload.newRecord;
              if (newRow['sender_id'] != userId) {
                // Incoming message from another student
                HapticFeedback.selectionClick();
                _ref.invalidate(conversationsProvider);
              }
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
    } catch (_) {}
    _notifChannel = null;
    _reqChannel = null;
    _msgChannel = null;
    _subscribedUserId = null;
  }
}
