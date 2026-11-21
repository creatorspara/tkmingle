import '../models/notification_model.dart';
import '../mock/seed_data.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> deleteNotification(String notificationId);
  Future<int> getUnreadCount(String userId);
}

class LocalNotificationRepository implements NotificationRepository {
  final List<NotificationModel> _notifications = List.from(SeedData.sampleNotifications);

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _notifications.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(read: true);
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId) {
        _notifications[i] = _notifications[i].copyWith(read: true);
      }
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    return _notifications.where((n) => n.userId == userId && !n.read).length;
  }
}
