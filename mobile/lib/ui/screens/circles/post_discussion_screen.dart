import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/auth_provider.dart';
import '../../../state/circle_provider.dart';
import '../../components/profile_avatar.dart';

class PostDiscussionScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDiscussionScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDiscussionScreen> createState() => _PostDiscussionScreenState();
}

class _PostDiscussionScreenState extends ConsumerState<PostDiscussionScreen> {
  final _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(authProvider).value;
    if (user == null) return;

    setState(() => _isSending = true);
    await ref.read(circleRepositoryProvider).addComment(
          postId: widget.postId,
          authorId: user.uid,
          authorName: user.name,
          authorDept: '${user.department} • ${user.academicYear}',
          content: text,
        );

    _commentController.clear();
    ref.invalidate(postDetailProvider(widget.postId));
    if (mounted) setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final postAsync = ref.watch(postDetailProvider(widget.postId));

    return postAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(appBar: AppBar(), body: Center(child: Text('Error: $err'))),
      data: (post) {
        if (post == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Post not found')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('${post.circleName} Discussion'),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Main Post Card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ProfileAvatar(
                                    imageUrl: post.authorImage,
                                    name: post.authorName,
                                    radius: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.authorName,
                                          style: AppTypography.titleMedium(
                                            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                          ),
                                        ),
                                        Text(
                                          post.authorDept,
                                          style: AppTypography.labelSmall(AppColors.secondaryAccent),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                post.content,
                                style: AppTypography.bodyLarge(
                                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ).copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: post.isLiked ? AppColors.highlightWarm : null,
                                    ),
                                    onPressed: () {
                                      ref.read(circleRepositoryProvider).toggleLikePost(post.postId);
                                      ref.invalidate(postDetailProvider(widget.postId));
                                    },
                                  ),
                                  Text('${post.likesCount} likes'),
                                  const Spacer(),
                                  Text(
                                    DateFormat('MMM d, h:mm a').format(post.createdAt),
                                    style: AppTypography.labelSmall(AppColors.darkTextMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Comments & Responses (${post.comments.length})',
                        style: AppTypography.titleMedium(
                          isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (post.comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No responses yet. Share your thoughts below!',
                              style: AppTypography.bodyMedium(AppColors.darkTextSecondary),
                            ),
                          ),
                        )
                      else
                        ...post.comments.map((comment) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        comment.authorName,
                                        style: AppTypography.labelLarge(
                                          isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('h:mm a').format(comment.createdAt),
                                        style: AppTypography.labelSmall(AppColors.darkTextMuted),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    comment.authorDept,
                                    style: AppTypography.labelSmall(AppColors.secondaryAccent),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    comment.content,
                                    style: AppTypography.bodyMedium(
                                      isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                // Comment input box
                Container(
                  padding: const EdgeInsets.all(12),
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
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Write a response...',
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          onSubmitted: (_) => _handleSendComment(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: AppColors.primaryAccent),
                        icon: _isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        onPressed: _isSending ? null : _handleSendComment,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
