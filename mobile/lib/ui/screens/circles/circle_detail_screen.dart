import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/post_model.dart';
import '../../../state/auth_provider.dart';
import '../../../state/circle_provider.dart';
import '../../components/custom_button.dart';
import '../../components/empty_state_view.dart';
import '../../components/profile_avatar.dart';
import '../../components/status_badge.dart';

class CircleDetailScreen extends ConsumerStatefulWidget {
  final String circleId;

  const CircleDetailScreen({super.key, required this.circleId});

  @override
  ConsumerState<CircleDetailScreen> createState() => _CircleDetailScreenState();
}

class _CircleDetailScreenState extends ConsumerState<CircleDetailScreen> {
  final _postController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _handleCreatePost(String circleName) async {
    final text = _postController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(authProvider).value;
    if (user == null) return;

    setState(() => _isPosting = true);
    await ref.read(circleRepositoryProvider).createPost(
          circleId: widget.circleId,
          circleName: circleName,
          authorId: user.uid,
          authorName: user.name,
          authorDept: '${user.department} • ${user.academicYear}',
          authorImage: user.profileImage,
          content: text,
        );

    _postController.clear();
    ref.invalidate(circlePostsProvider(widget.circleId));
    if (mounted) setState(() => _isPosting = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(authProvider).value;
    final circleAsync = ref.watch(circleDetailProvider(widget.circleId));
    final postsAsync = ref.watch(circlePostsProvider(widget.circleId));

    return circleAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(appBar: AppBar(), body: Center(child: Text('Error: $err'))),
      data: (circle) {
        if (circle == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Circle not found')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(circle.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invite link copied for ${circle.name}!')),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header Details
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primaryAccent.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Text(circle.icon, style: const TextStyle(fontSize: 28)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    circle.name,
                                    style: AppTypography.headlineLarge(
                                      isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      StatusBadge(
                                        text: circle.category,
                                        color: AppColors.secondaryAccent,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${circle.memberCount} Campus Members',
                                        style: AppTypography.bodyMedium(
                                          isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          circle.description,
                          style: AppTypography.bodyLarge(
                            isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Join / Leave Button
                        CustomButton(
                          text: circle.isMember ? 'Leave Circle' : 'Join This Circle',
                          icon: circle.isMember ? Icons.check : Icons.group_add,
                          variant: circle.isMember ? ButtonVariant.outline : ButtonVariant.primary,
                          width: double.infinity,
                          onPressed: () async {
                            if (currentUser == null) return;
                            final repo = ref.read(circleRepositoryProvider);
                            if (circle.isMember) {
                              await repo.leaveCircle(circle.circleId, currentUser.uid);
                            } else {
                              await repo.joinCircle(circle.circleId, currentUser.uid);
                            }
                            ref.invalidate(circleDetailProvider(widget.circleId));
                            ref.invalidate(circlesListProvider);
                            ref.invalidate(joinedCirclesProvider);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // New Post Input Area (if member)
                if (circle.isMember)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _postController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                hintText: 'Share an update, question, or project invite with this circle...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                fillColor: Colors.transparent,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                  ),
                                  onPressed: _isPosting ? null : () => _handleCreatePost(circle.name),
                                  child: _isPosting
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Text('Post to Circle'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Posts Feed Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      'Discussion Threads',
                      style: AppTypography.titleMedium(
                        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ),
                // Posts Feed List
                postsAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
                  ),
                  error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
                  data: (posts) {
                    if (posts.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: EmptyStateView(
                            icon: Icons.chat_outlined,
                            title: 'No Discussions Yet',
                            message: 'Start the conversation by posting an update or question to this circle!',
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = posts[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: _PostTile(post: post),
                          );
                        },
                        childCount: posts.length,
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PostTile extends ConsumerWidget {
  final PostModel post;

  const _PostTile({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/post/${post.postId}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProfileAvatar(
                    imageUrl: post.authorImage,
                    name: post.authorName,
                    radius: 20,
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
              const SizedBox(height: 12),
              Text(
                post.content,
                style: AppTypography.bodyLarge(
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: post.isLiked ? AppColors.highlightWarm : null,
                    ),
                    onPressed: () {
                      ref.read(circleRepositoryProvider).toggleLikePost(post.postId);
                      ref.invalidate(circlePostsProvider(post.circleId));
                    },
                  ),
                  Text('${post.likesCount}'),
                  const SizedBox(width: 18),
                  const Icon(Icons.mode_comment_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text('${post.commentsCount} comments'),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.darkTextMuted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
