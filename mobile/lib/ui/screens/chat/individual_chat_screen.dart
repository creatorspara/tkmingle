import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/college_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/message_model.dart';
import '../../../state/auth_provider.dart';
import '../../../state/chat_provider.dart';
import '../../components/profile_avatar.dart';
import '../safety/report_block_sheet.dart';

class IndividualChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const IndividualChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends ConsumerState<IndividualChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Mark messages as read on entry
    Future.microtask(() {
      final user = ref.read(authProvider).value;
      if (user != null) {
        ref.read(messageRepositoryProvider).markAsRead(widget.conversationId, user.uid);
        ref.invalidate(conversationsProvider);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSend({String? prefillText, MessageType type = MessageType.text, String? attachmentUrl}) async {
    final text = prefillText ?? _textController.text.trim();
    if (text.isEmpty && attachmentUrl == null) return;

    final user = ref.read(authProvider).value;
    if (user == null) return;

    HapticFeedback.lightImpact();
    _textController.clear();

    await ref.read(messageRepositoryProvider).sendMessage(
          conversationId: widget.conversationId,
          senderId: user.uid,
          message: text,
          type: type,
          attachmentUrl: attachmentUrl,
        );

    ref.invalidate(conversationsProvider);

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendPhotoAttachment() {
    final samplePhotos = [
      'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&w=600&q=80',
    ];
    final selectedPhoto = samplePhotos[DateTime.now().millisecond % samplePhotos.length];
    _handleSend(type: MessageType.image, attachmentUrl: selectedPhoto);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(authProvider).value;
    final messagesStream = ref.watch(messagesProvider(widget.conversationId));
    final conversations = ref.watch(conversationsProvider).value ?? [];

    final currentConv = conversations
        .where((c) => c.conversationId == widget.conversationId)
        .firstOrNull;
    final otherUser = currentConv?.otherUser;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: otherUser != null
            ? InkWell(
                onTap: () => context.push('/profile/${otherUser.uid}'),
                child: Row(
                  children: [
                    ProfileAvatar(
                      imageUrl: otherUser.profileImage,
                      name: otherUser.name,
                      avatarType: otherUser.avatarType,
                      avatarId: otherUser.avatarId,
                      radius: 19,
                      isOnline: true,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            otherUser.name,
                            style: AppTypography.titleMedium(
                              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            '${otherUser.department} • Active Now',
                            style: AppTypography.labelSmall(AppColors.highlight),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {
              if (otherUser != null) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => ReportBlockSheet(
                    targetUserId: otherUser.uid,
                    targetUserName: otherUser.name,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: messagesStream.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (messages) {
                  if (messages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'You are connected! Send a message or pick an icebreaker below to break the ice.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium(AppColors.darkTextSecondary),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == currentUser?.uid;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.76,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                          decoration: BoxDecoration(
                            gradient: isMe ? AppColors.primaryGradient : null,
                            color: isMe ? null : (isDark ? AppColors.darkCard : AppColors.lightCard),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                              bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                            ),
                            border: isMe
                                ? null
                                : Border.all(
                                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                  ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (msg.type == MessageType.image && msg.attachmentUrl != null) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    msg.attachmentUrl!,
                                    fit: BoxFit.cover,
                                    height: 180,
                                    width: double.infinity,
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],
                              if (msg.message.isNotEmpty)
                                Text(
                                  msg.message,
                                  style: AppTypography.bodyLarge(
                                    isMe
                                        ? Colors.white
                                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    DateFormat('h:mm a').format(msg.timestamp),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMe
                                          ? Colors.white70
                                          : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                    ),
                                  ),
                                  if (isMe) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.done_all_rounded,
                                      size: 13,
                                      color: Colors.white70,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Icebreaker Chips Carousel
            Container(
              height: 38,
              margin: const EdgeInsets.only(bottom: 6),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: CollegeData.icebreakers.map((ib) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: const Icon(Icons.flash_on, size: 14, color: AppColors.highlight),
                      label: Text(
                        ib,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => _handleSend(prefillText: ib, type: MessageType.icebreaker),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Message Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_camera_outlined, color: AppColors.primaryAccent),
                    onPressed: _sendPhotoAttachment,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Type a message to your college peer...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: AppColors.primaryAccent),
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: () => _handleSend(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
