import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/chat_provider.dart';
import '../../components/empty_state_view.dart';
import '../../components/profile_avatar.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    // Auto-refresh conversations when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(conversationsProvider);
    });

    // Active polling fallback every 4 seconds while user is on this screen
    // ensures instant receipt even if Wi-Fi / WebSockets experienced brief packet loss
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        ref.invalidate(conversationsProvider);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    return ref.refresh(conversationsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                color: isDark ? AppColors.tkmPurple.withOpacity(0.12) : AppColors.tkmPurple.withOpacity(0.08),
                border: Border.all(
                  color: isDark ? AppColors.tkmPurple.withOpacity(0.3) : AppColors.tkmPurple.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Image.asset('assets/images/app_icon.png', fit: BoxFit.contain),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Messages',
                  style: AppTypography.headlineLarge(
                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  'Connected Campus Chats',
                  style: AppTypography.labelSmall(
                    isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Messages',
            onPressed: () => ref.refresh(conversationsProvider.future),
          ),
          IconButton(
            icon: const Icon(Icons.people_outline_rounded),
            tooltip: 'My Connections',
            onPressed: () => context.push('/connections'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.tkmPurple,
          child: conversationsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.tkmPurple),
            ),
            error: (err, _) => Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 40, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text('Error loading chats: $err', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refresh,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (conversations) {
              if (conversations.isEmpty) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    child: EmptyStateView(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'No Conversations Yet',
                      message:
                          'Once you connect with a fellow TKMCE student, your private real-time chats will appear here instantly.',
                      buttonText: 'Discover Students',
                      onButtonPressed: () => context.go('/discover'),
                    ),
                  ),
                );
              }

              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: conversations.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                itemBuilder: (context, index) {
                  final conv = conversations[index];
                  final other = conv.otherUser;
                  if (other == null) return const SizedBox.shrink();

                  final hasUnread = conv.unreadCount > 0;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    leading: ProfileAvatar(
                      imageUrl: other.profileImage,
                      name: other.name,
                      avatarType: other.avatarType,
                      avatarId: other.avatarId,
                      radius: 26,
                      isOnline: true,
                      showVerifiedBadge: other.verified,
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            other.name,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.titleMedium(
                              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ).copyWith(
                              fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('h:mm a').format(conv.lastMessageAt),
                          style: AppTypography.labelSmall(
                            hasUnread ? AppColors.primaryAccent : AppColors.darkTextMuted,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              conv.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMedium(
                                hasUnread
                                    ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              ).copyWith(
                                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (hasUnread) ...[
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: AppColors.primaryAccent,
                              child: Text(
                                '${conv.unreadCount}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    onTap: () async {
                      await context.push('/chat/${conv.conversationId}');
                      // When returning from chat, refresh immediately
                      if (mounted) {
                        ref.invalidate(conversationsProvider);
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
