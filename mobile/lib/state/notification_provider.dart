import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/notification_repository.dart';
import 'auth_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return LocalNotificationRepository();
});

final notificationsListProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  return repo.getNotifications(user.uid);
});

final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  final user = ref.watch(authProvider).value;
  if (user == null) return 0;
  return repo.getUnreadCount(user.uid);
});
