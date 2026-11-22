import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/realtime_notification_service.dart';
import '../../core/services/update_service.dart';
import '../../core/theme/app_colors.dart';
import '../../state/chat_provider.dart';
import '../../state/connection_provider.dart';
import '../../state/notification_provider.dart';
import 'update_dialog.dart';

class TKMingleScaffold extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const TKMingleScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<TKMingleScaffold> createState() => _TKMingleScaffoldState();
}

class _TKMingleScaffoldState extends ConsumerState<TKMingleScaffold> {
  static bool _hasCheckedForUpdates = false;

  @override
  void initState() {
    super.initState();
    if (!_hasCheckedForUpdates) {
      _hasCheckedForUpdates = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          final update = await UpdateService.checkForUpdate();
          if (mounted && update != null) {
            UpdateDialog.show(context, update);
          }
        } catch (e) {
          debugPrint("Automatic update check notice: $e");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep Supabase Realtime notification listener active
    ref.watch(realtimeNotificationServiceProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unreadNotifs = ref.watch(unreadNotificationsCountProvider).value ?? 0;
    final pendingRequests = ref.watch(receivedRequestsProvider).value ?? [];
    final totalAlerts = unreadNotifs + pendingRequests.length;
    final conversations = ref.watch(conversationsProvider).value ?? [];
    final unreadMessages = conversations.fold<int>(0, (sum, c) => sum + c.unreadCount);

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.deepNavy : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.border : AppColors.lightBorder,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: (index) {
              widget.navigationShell.goBranch(
                index,
                initialLocation: index == widget.navigationShell.currentIndex,
              );
            },
            backgroundColor: Colors.transparent,
            indicatorColor: AppColors.tkmPurple.withOpacity(0.25),
            surfaceTintColor: Colors.transparent,
            height: 64,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore, color: AppColors.tkmPurple),
                label: 'Discover',
              ),
              const NavigationDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups, color: AppColors.tkmPurple),
                label: 'Circles',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: unreadMessages > 0,
                  label: Text('$unreadMessages'),
                  backgroundColor: AppColors.tkmPurple,
                  child: const Icon(Icons.chat_bubble_outline),
                ),
                selectedIcon: Badge(
                  isLabelVisible: unreadMessages > 0,
                  label: Text('$unreadMessages'),
                  backgroundColor: AppColors.tkmPurple,
                  child: const Icon(Icons.chat_bubble, color: AppColors.tkmPurple),
                ),
                label: 'Messages',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: totalAlerts > 0,
                  label: Text('$totalAlerts'),
                  backgroundColor: AppColors.error,
                  child: const Icon(Icons.notifications_none),
                ),
                selectedIcon: Badge(
                  isLabelVisible: totalAlerts > 0,
                  label: Text('$totalAlerts'),
                  backgroundColor: AppColors.error,
                  child: const Icon(Icons.notifications, color: AppColors.tkmPurple),
                ),
                label: 'Alerts',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: AppColors.tkmPurple),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
