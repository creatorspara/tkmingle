import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/chat_provider.dart';
import '../../components/empty_state_view.dart';
import '../../components/profile_avatar.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            icon: const Icon(Icons.people_outline_rounded),
            tooltip: 'My Connections',
            onPressed: () => context.push('/connections'),
          ),
        ],
      ),
      body: SafeArea(
        child: conversationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (conversations) {
            if (conversations.isEmpty) {
              return EmptyStateView(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'No Conversations Yet',
                message: 'Once you connect with a fellow TKMCE student, your private real-time chats will appear here.',
                buttonText: 'Discover Students',
                onButtonPressed: () => context.go('/discover'),
              );
            }

            return ListView.separated(
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
                              style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  onTap: () {
                    context.push('/chat/${conv.conversationId}');
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
