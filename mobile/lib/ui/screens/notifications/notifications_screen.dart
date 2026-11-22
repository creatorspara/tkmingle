import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/auth_provider.dart';
import '../../../state/connection_provider.dart';
import '../../../state/notification_provider.dart';
import '../../components/empty_state_view.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(authProvider).value;
    final notificationsAsync = ref.watch(notificationsListProvider);
    final receivedRequests = ref.watch(receivedRequestsProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                color: AppColors.secondaryBackground,
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/images/app_icon.png', fit: BoxFit.cover),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: AppTypography.headlineLarge(
                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  'Activity & Campus Updates',
                  style: AppTypography.labelSmall(
                    isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (currentUser != null) {
                await ref.read(notificationRepositoryProvider).markAllAsRead(currentUser.uid);
                ref.invalidate(notificationsListProvider);
                ref.invalidate(unreadNotificationsCountProvider);
              }
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (receivedRequests.isNotEmpty)
              InkWell(
                onTap: () => context.push('/requests'),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface : AppColors.lightCardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.tkmPurple.withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.tkmPurple.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.tkmPurple.withOpacity(0.2),
                        ),
                        child: const Icon(Icons.people_alt, color: AppColors.tkmPurple, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Connection Requests',
                                  style: AppTypography.titleMedium(
                                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.tkmPurple,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${receivedRequests.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tap to view and respond to incoming requests',
                              style: AppTypography.bodySmall(
                                isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.tkmPurple),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: notificationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return const EmptyStateView(
                      icon: Icons.notifications_none_rounded,
                      title: 'No Notifications',
                      message: 'You are all caught up! New connection requests, messages, and circle updates will notify you here.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    itemBuilder: (context, index) {
                final notif = notifications[index];
                return Dismissible(
                  key: Key(notif.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: AppColors.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref.read(notificationRepositoryProvider).deleteNotification(notif.id);
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    tileColor: notif.read
                        ? Colors.transparent
                        : AppColors.primaryAccent.withOpacity(0.06),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _getIconBg(notif.type),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_getIcon(notif.type), color: _getIconColor(notif.type), size: 22),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: AppTypography.titleMedium(
                              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ).copyWith(
                              fontWeight: notif.read ? FontWeight.w500 : FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('MMM d, h:mm a').format(notif.createdAt),
                          style: AppTypography.labelSmall(AppColors.darkTextMuted),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        notif.body,
                        style: AppTypography.bodyMedium(
                          isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    onTap: () {
                      ref.read(notificationRepositoryProvider).markAsRead(notif.id);
                      ref.invalidate(notificationsListProvider);
                      ref.invalidate(unreadNotificationsCountProvider);

                      if (notif.type == 'connection_request') {
                        context.push('/requests');
                      } else if (notif.type == 'connection_accepted' && notif.referenceId.isNotEmpty) {
                        context.push('/profile/${notif.referenceId}');
                      } else if (notif.type == 'circle_post' && notif.referenceId.isNotEmpty) {
                        context.push('/post/${notif.referenceId}');
                      }
                    },
                  ),
                );
              },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'connection_request':
        return Icons.person_add_alt_1_rounded;
      case 'connection_accepted':
        return Icons.celebration_rounded;
      case 'new_message':
        return Icons.chat_bubble_outline_rounded;
      case 'circle_post':
        return Icons.groups_rounded;
      default:
        return Icons.verified_user_rounded;
    }
  }

  Color _getIconBg(String type) {
    switch (type) {
      case 'connection_accepted':
        return AppColors.highlight.withOpacity(0.18);
      case 'circle_post':
        return AppColors.secondaryAccent.withOpacity(0.18);
      default:
        return AppColors.primaryAccent.withOpacity(0.18);
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'connection_accepted':
        return AppColors.highlight;
      case 'circle_post':
        return AppColors.secondaryAccent;
      default:
        return AppColors.primaryAccent;
    }
  }
}
