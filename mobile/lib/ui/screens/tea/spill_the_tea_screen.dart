import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/services/imgbb_resolver.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/tea_post_model.dart';
import '../../../state/auth_provider.dart';
import '../../../state/tea_provider.dart';
import '../../components/alias_avatar.dart';
import '../../components/profile_avatar.dart';

class SpillTheTeaScreen extends ConsumerStatefulWidget {
  const SpillTheTeaScreen({super.key});

  @override
  ConsumerState<SpillTheTeaScreen> createState() => _SpillTheTeaScreenState();
}

class _SpillTheTeaScreenState extends ConsumerState<SpillTheTeaScreen> {
  String _filter = 'all'; // all, tea, quote, anonymous, profiled
  String _sort = 'latest'; // latest, spicy
  final Set<String> _expandedComments = {};
  final Set<String> _reportedPostIds = {};
  final Map<String, TextEditingController> _commentControllers = {};
  final Map<String, bool> _commentAnonMap = {};

  @override
  void dispose() {
    for (final c in _commentControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _getCommentController(String postId) {
    return _commentControllers.putIfAbsent(postId, () => TextEditingController());
  }

  void _openCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _CreateTeaSheet(),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (c, u) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (c, u, e) => Container(
                    padding: const EdgeInsets.all(20),
                    color: AppColors.surface,
                    child: const Text('Failed to load image link'),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportTeaDialog(BuildContext context, TeaPost item) {
    String selectedReason = 'Defamation or Personal Target';
    final detailsController = TextEditingController();
    bool isSubmitting = false;

    final reasons = [
      'Defamation or Personal Target',
      'Harassment or Hate Speech',
      'Inappropriate / NSFW Content',
      'False Rumors / Misinformation',
      'Spam or Unsolicited Promotion',
      'Other Violation',
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.surface : AppColors.lightCardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.flag, color: Colors.redAccent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Tea Post',
                      style: AppTypography.titleMedium(
                        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Flagged for admin moderation',
                      style: AppTypography.labelSmall(
                        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post snippet card
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.deepNavy : AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.border : AppColors.lightBorder,
                    ),
                  ),
                  child: Text(
                    item.content.length > 120
                        ? '${item.content.substring(0, 120)}...'
                        : item.content,
                    style: AppTypography.bodySmall(
                      isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Reason for Report',
                  style: AppTypography.labelLarge(
                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.deepNavy : AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.border : AppColors.lightBorder,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedReason,
                      isExpanded: true,
                      dropdownColor: isDark ? AppColors.surface : AppColors.lightCardBackground,
                      items: reasons.map((r) {
                        return DropdownMenuItem<String>(
                          value: r,
                          child: Text(
                            r,
                            style: AppTypography.bodySmall(
                              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedReason = val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Additional Details (Optional)',
                  style: AppTypography.labelLarge(
                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: detailsController,
                  maxLines: 3,
                  style: AppTypography.bodySmall(
                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Describe why this post violates guidelines...',
                    hintStyle: AppTypography.bodySmall(
                      isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.deepNavy : AppColors.lightBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.border : AppColors.lightBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.border : AppColors.lightBorder,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setDialogState(() => isSubmitting = true);
                      try {
                        await ref.read(teaFeedProvider.notifier).reportPost(
                              postId: item.id,
                              reason: selectedReason,
                              details: detailsController.text.trim().isNotEmpty
                                  ? detailsController.text.trim()
                                  : null,
                            );
                        setState(() {
                          _reportedPostIds.add(item.id);
                        });
                        if (context.mounted) {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Report submitted to admin for review. Thank you!'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to submit report: $e')),
                          );
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teaState = ref.watch(teaFeedProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNavy : AppColors.lightBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.tkmPurple.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.coffee, color: AppColors.tkmPurple, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Spill the Tea ☕',
              style: AppTypography.headlineMedium(
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Feed',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(teaFeedProvider.notifier).loadPosts(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(teaFeedProvider.notifier).loadPosts(),
          color: AppColors.tkmPurple,
          child: Column(
            children: [
              // 1. Top Action Callout Banner
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Campus Confessions & Quotes',
                            style: AppTypography.titleSmall(
                              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Anonymous Malayalam pop culture whispers at TKMCE',
                            style: AppTypography.labelSmall(
                              isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _openCreateSheet(context),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Spill Tea'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tkmPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Filter & Sort Horizontal Strip
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : AppColors.lightCardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.border : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _filterChip('all', 'All Buzz'),
                            const SizedBox(width: 6),
                            _filterChip('tea', '🍵 Hot Tea'),
                            const SizedBox(width: 6),
                            _filterChip('quote', '💬 Quotes'),
                            const SizedBox(width: 6),
                            _filterChip('anonymous', '👁️ Anonymous'),
                            const SizedBox(width: 6),
                            _filterChip('profiled', '👤 Profiled'),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 24,
                      width: 1,
                      color: isDark ? AppColors.border : AppColors.lightBorder,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    PopupMenuButton<String>(
                      initialValue: _sort,
                      icon: Icon(
                        _sort == 'spicy' ? Icons.whatshot : Icons.bolt,
                        color: _sort == 'spicy' ? AppColors.accentTeal : AppColors.tkmPurple,
                        size: 20,
                      ),
                      tooltip: 'Sort By',
                      onSelected: (val) => setState(() => _sort = val),
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'latest',
                          child: Text('⚡ Latest'),
                        ),
                        const PopupMenuItem(
                          value: 'spicy',
                          child: Text('🔥 Spiciest'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. Post Feed
              Expanded(
                child: teaState.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.tkmPurple),
                  ),
                  error: (err, _) => Center(
                    child: Text('Error loading feed: $err'),
                  ),
                  data: (posts) {
                    var filtered = posts.where((p) {
                      if (_filter == 'tea') return p.type == 'tea' || p.type == 'confession';
                      if (_filter == 'quote') return p.type == 'quote';
                      if (_filter == 'anonymous') return p.authorType == 'anonymous';
                      if (_filter == 'profiled') return p.authorType == 'profiled';
                      return true;
                    }).toList();

                    if (_sort == 'spicy') {
                      filtered.sort((a, b) =>
                          (b.likesCount + b.firesCount).compareTo(a.likesCount + a.firesCount));
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.coffee_maker_outlined, size: 54, color: AppColors.tkmPurple),
                            const SizedBox(height: 12),
                            Text(
                              'No tea spilled here yet!',
                              style: AppTypography.titleMedium(
                                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Be the first to share an anonymous campus scoop.',
                              style: AppTypography.bodySmall(
                                isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (context, idx) {
                        final item = filtered[idx];
                        return _buildPostCard(context, item, isDark);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String id, String label) {
    final isSelected = _filter == id;
    return GestureDetector(
      onTap: () => setState(() => _filter = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tkmPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall(
            isSelected ? Colors.white : AppColors.darkTextMuted,
          ).copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, TeaPost item, bool isDark) {
    final isAnon = item.isAnonymous;
    final isExpanded = _expandedComments.contains(item.id);
    final commentCtrl = _getCommentController(item.id);
    final isAnonComment = _commentAnonMap[item.id] ?? true;
    final currentUser = ref.watch(authProvider).value;
    final isAuthor = currentUser != null && item.userId != null && currentUser.uid == item.userId;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Post Header: Avatar, Name, (Anonymous Post) tag
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isAnon)
                  AliasAvatar(alias: item.aliasModel, radius: 22)
                else
                  ProfileAvatar(
                    imageUrl: item.authorAvatar ?? '',
                    name: item.authorName,
                    radius: 22,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Text(
                            isAnon ? (item.anonymousAlias ?? 'Dasamoolam Damu') : item.authorName,
                            style: AppTypography.titleSmall(
                              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (isAnon)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.tkmPurple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.tkmPurple.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.visibility_off, size: 10, color: AppColors.tkmPurple),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(Anonymous Post)',
                                    style: AppTypography.labelSmall(AppColors.tkmPurple).copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accentTeal.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.accentTeal.withOpacity(0.3)),
                              ),
                              child: Text(
                                'Profiled',
                                style: AppTypography.labelSmall(AppColors.accentTeal).copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_formatTimeAgo(item.createdAt)} • ${item.department}',
                        style: AppTypography.labelSmall(
                          isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Post Title (if present)
          if (item.title != null && item.title!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              child: Text(
                item.title!,
                style: AppTypography.titleMedium(
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ),

          // 3. Post Content (Quote vs Tea)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: item.type == 'quote'
                ? Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.tkmPurple.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border(
                        left: BorderSide(color: AppColors.tkmPurple, width: 3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.content,
                          style: AppTypography.bodyMedium(
                            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ).copyWith(
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                        if (item.quoteAuthor != null && item.quoteAuthor!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '— ${item.quoteAuthor}',
                            style: AppTypography.labelSmall(AppColors.tkmPurple).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : Text(
                    item.content,
                    style: AppTypography.bodyMedium(
                      isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ).copyWith(height: 1.4),
                  ),
          ),

          // 4. Image Attachment (with tap-to-view fullscreen)
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
              child: GestureDetector(
                onTap: () => _showImageDialog(context, item.imageUrl!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        placeholder: (c, u) => Container(
                          height: 200,
                          color: Colors.black26,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (c, u, e) => Container(
                          height: 100,
                          color: Colors.black26,
                          child: const Center(child: Text('Image attachment unavailable')),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.fullscreen, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('Enlarge', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 5. Actions: Like, Fire, Comments count, Comments toggle, Share
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Row(
              children: [
                // 🍵 Like
                _actionButton(
                  icon: '🍵',
                  count: item.likesCount,
                  isActive: item.isLiked,
                  activeColor: AppColors.accentTeal,
                  onTap: () => ref
                      .read(teaFeedProvider.notifier)
                      .toggleReaction(item.id, isFire: false),
                ),
                const SizedBox(width: 8),

                // 🔥 Fire
                _actionButton(
                  icon: '🔥',
                  count: item.firesCount,
                  isActive: item.isFired,
                  activeColor: Colors.orange,
                  onTap: () => ref
                      .read(teaFeedProvider.notifier)
                      .toggleReaction(item.id, isFire: true),
                ),
                const SizedBox(width: 8),

                // 💬 Comments Toggle
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedComments.remove(item.id);
                      } else {
                        _expandedComments.add(item.id);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.deepNavy : AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? AppColors.border : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${item.comments.length}',
                          style: AppTypography.labelSmall(
                            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        if (!item.allowComments) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.lock, size: 10, color: Colors.amber),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Author Toggle Comments ON / OFF (Only visible to author)
                if (isAuthor)
                  IconButton(
                    tooltip: item.allowComments ? 'Turn Comments OFF' : 'Turn Comments ON',
                    icon: Icon(
                      item.allowComments ? Icons.lock_open : Icons.lock,
                      size: 16,
                      color: item.allowComments ? AppColors.darkTextMuted : Colors.amber,
                    ),
                    onPressed: () =>
                        ref.read(teaFeedProvider.notifier).toggleAllowComments(item.id),
                  ),

                const Spacer(),

                // Report Tea to Admin (Only on other students' posts, not self)
                if (!isAuthor)
                  IconButton(
                    tooltip: _reportedPostIds.contains(item.id)
                        ? 'Report submitted to admin'
                        : 'Report Tea to Admin',
                    icon: Icon(
                      _reportedPostIds.contains(item.id)
                          ? Icons.check_circle_outline
                          : Icons.flag_outlined,
                      size: 18,
                      color: _reportedPostIds.contains(item.id)
                          ? AppColors.accentTeal
                          : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                    ),
                    onPressed: _reportedPostIds.contains(item.id)
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You have already reported this post. Our moderation team is reviewing it.'),
                              ),
                            );
                          }
                        : () => _showReportTeaDialog(context, item),
                  ),

                // Share / Copy
                IconButton(
                  tooltip: 'Copy Tea Scoop',
                  icon: const Icon(Icons.share_outlined, size: 18),
                  onPressed: () {
                    final shareText = item.type == 'quote'
                        ? '"${item.content}"\n— ${item.quoteAuthor ?? "TKMCE"}\n(Shared from TKMingle Spill the Tea)'
                        : '${item.title != null ? "${item.title}\n\n" : ""}${item.content}\n(Shared from TKMingle Spill the Tea)';
                    Clipboard.setData(ClipboardData(text: shareText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard!')),
                    );
                  },
                ),
              ],
            ),
          ),

          // 6. Comments Section (Expanded)
          if (isExpanded) ...[
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.all(12),
              color: isDark ? AppColors.deepNavy.withOpacity(0.5) : AppColors.lightSurface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!item.allowComments)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.lock, color: Colors.amber, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'The author has turned off comments for this post.',
                              style: TextStyle(color: Colors.amber, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Comment list
                  if (item.comments.isNotEmpty) ...[
                    ...item.comments.map((comm) {
                      final isCommAnon = comm.authorType == 'anonymous';
                      final commAlias = MalayalamAlias.findByName(comm.authorAlias ?? comm.authorName);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isCommAnon)
                              AliasAvatar(alias: commAlias, radius: 12)
                            else
                              ProfileAvatar(
                                imageUrl: comm.authorAvatar ?? '',
                                name: comm.authorName,
                                radius: 12,
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surface : AppColors.lightCardBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          comm.authorName,
                                          style: AppTypography.labelSmall(
                                            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                          ).copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        if (isCommAnon) ...[
                                          const SizedBox(width: 4),
                                          Text(
                                            '(Anonymous)',
                                            style: TextStyle(
                                              color: AppColors.tkmPurple.withOpacity(0.9),
                                              fontSize: 9,
                                            ),
                                          ),
                                        ],
                                        const Spacer(),
                                        Text(
                                          _formatTimeAgo(comm.createdAt),
                                          style: TextStyle(
                                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      comm.content,
                                      style: AppTypography.bodySmall(
                                        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ] else if (item.allowComments)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'No comments yet. Chime in first!',
                        style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ),

                  // Add comment input (only if comments allowed)
                  if (item.allowComments) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentCtrl,
                            style: AppTypography.bodySmall(
                              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: isAnonComment ? 'Reply anonymously...' : 'Reply as profile...',
                              hintStyle: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.send, size: 18, color: AppColors.tkmPurple),
                          onPressed: () {
                            final text = commentCtrl.text.trim();
                            if (text.isNotEmpty) {
                              ref.read(teaFeedProvider.notifier).addComment(
                                    item.id,
                                    text,
                                    isAnonymous: isAnonComment,
                                  );
                              commentCtrl.clear();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _commentAnonMap[item.id] = !isAnonComment;
                        });
                      },
                      child: Text(
                        isAnonComment
                            ? '🎭 Replying anonymously (Tap to reply as profile)'
                            : '👤 Replying with profile (Tap to reply anonymously)',
                        style: TextStyle(
                          color: isAnonComment ? AppColors.tkmPurple : AppColors.accentTeal,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButton({
    required String icon,
    required int count,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withOpacity(0.18)
              : (isDark ? AppColors.deepNavy : AppColors.lightBackground),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? activeColor.withOpacity(0.5)
                : (isDark ? AppColors.border : AppColors.lightBorder),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: AppTypography.labelSmall(
                isActive
                    ? activeColor
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateTeaSheet extends ConsumerStatefulWidget {
  const _CreateTeaSheet();

  @override
  ConsumerState<_CreateTeaSheet> createState() => _CreateTeaSheetState();
}

class _CreateTeaSheetState extends ConsumerState<_CreateTeaSheet> {
  String _postType = 'tea'; // tea, quote, confession
  bool _isAnonymous = true;
  MalayalamAlias _selectedAlias = MalayalamAlias.all[0];
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _quoteAuthorController = TextEditingController();
  final _imageController = TextEditingController();
  bool _allowComments = true;
  bool _isSubmitting = false;
  bool _isResolvingImgbb = false;
  String? _imgbbStatus;
  bool _imgbbHasError = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _quoteAuthorController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _rollRandomAlias() {
    final next = (MalayalamAlias.all..shuffle()).first;
    setState(() => _selectedAlias = next);
  }

  Future<void> _handleImageUrlChanged(String val) async {
    final raw = val.trim();
    if (raw.isEmpty) {
      setState(() {
        _imgbbStatus = null;
        _imgbbHasError = false;
        _isResolvingImgbb = false;
      });
      return;
    }

    if (!ImgbbResolver.isImgbbHost(raw)) {
      setState(() {
        _imgbbStatus = 'Only ImgBB links (ibb.co or i.ibb.co) are allowed.';
        _imgbbHasError = true;
        _isResolvingImgbb = false;
      });
      return;
    }

    if (ImgbbResolver.isDirectImage(raw)) {
      setState(() {
        _imgbbStatus = '✓ Valid direct ImgBB image link';
        _imgbbHasError = false;
        _isResolvingImgbb = false;
      });
      return;
    }

    // It is an ibb.co page link -> resolve it to direct image
    setState(() {
      _isResolvingImgbb = true;
      _imgbbStatus = 'Resolving ImgBB page link to direct image URL...';
      _imgbbHasError = false;
    });

    try {
      final directUrl = await ImgbbResolver.resolveToDirectUrl(raw);
      if (mounted) {
        _imageController.text = directUrl;
        setState(() {
          _isResolvingImgbb = false;
          _imgbbStatus = '✓ Converted to direct image URL!';
          _imgbbHasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResolvingImgbb = false;
          _imgbbStatus = 'Could not resolve ImgBB link: ${e.toString().replaceAll('Exception: ', '').replaceAll('FormatException: ', '')}';
          _imgbbHasError = true;
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter details or quote text')),
      );
      return;
    }

    String imageUrl = _imageController.text.trim();
    if (imageUrl.isNotEmpty) {
      if (!ImgbbResolver.isImgbbHost(imageUrl)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only ImgBB links (ibb.co) are supported for Spill the Tea.')),
        );
        return;
      }

      if (!ImgbbResolver.isDirectImage(imageUrl)) {
        setState(() => _isSubmitting = true);
        try {
          imageUrl = await ImgbbResolver.resolveToDirectUrl(imageUrl);
          _imageController.text = imageUrl;
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to resolve ImgBB image link: $e')),
          );
          setState(() => _isSubmitting = false);
          return;
        }
      }
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(teaFeedProvider.notifier).createPost(
            type: _postType,
            isAnonymous: _isAnonymous,
            selectedAlias: _selectedAlias,
            title: _titleController.text.trim(),
            content: content,
            quoteAuthor: _quoteAuthorController.text.trim(),
            imageUrl: imageUrl,
            allowComments: _allowComments,
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tea spilled successfully! ☕')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.border : AppColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.coffee, color: AppColors.tkmPurple),
                    const SizedBox(width: 8),
                    Text(
                      'Spill Tea or Post a Quote',
                      style: AppTypography.titleMedium(
                        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Scrollable Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Identity Switch: Anonymous vs Profiled
                  Text(
                    'POSTING IDENTITY',
                    style: AppTypography.labelSmall(AppColors.darkTextMuted).copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isAnonymous = true),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isAnonymous
                                  ? AppColors.tkmPurple.withOpacity(0.18)
                                  : (isDark ? AppColors.deepNavy : AppColors.lightBackground),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _isAnonymous ? AppColors.tkmPurple : (isDark ? AppColors.border : AppColors.lightBorder),
                                width: _isAnonymous ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.visibility_off, color: AppColors.tkmPurple, size: 16),
                                    SizedBox(width: 6),
                                    Text('Anonymous', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Uses a Malayalam pop culture alias',
                                  style: TextStyle(fontSize: 10, color: AppColors.darkTextMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isAnonymous = false),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: !_isAnonymous
                                  ? AppColors.accentTeal.withOpacity(0.18)
                                  : (isDark ? AppColors.deepNavy : AppColors.lightBackground),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: !_isAnonymous ? AppColors.accentTeal : (isDark ? AppColors.border : AppColors.lightBorder),
                                width: !_isAnonymous ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.person, color: AppColors.accentTeal, size: 16),
                                    SizedBox(width: 6),
                                    Text('With Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Shows your real student name',
                                  style: TextStyle(fontSize: 10, color: AppColors.darkTextMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 2. Character Picker Grid (When Anonymous)
                  if (_isAnonymous) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.tkmPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.tkmPurple.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              AliasAvatar(alias: _selectedAlias, radius: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('SELECTED ALIAS:', style: TextStyle(fontSize: 9, color: AppColors.darkTextMuted)),
                                    Row(
                                      children: [
                                        Text(
                                          _selectedAlias.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '(Anonymous Post)',
                                          style: TextStyle(fontSize: 10, color: AppColors.tkmPurple.withOpacity(0.9)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: _rollRandomAlias,
                                icon: const Icon(Icons.shuffle, size: 14),
                                label: const Text('Roll', style: TextStyle(fontSize: 11)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.tkmPurple,
                                  side: const BorderSide(color: AppColors.tkmPurple),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'CHOOSE YOUR CHARACTER FACE & ALIAS:',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextMuted),
                          ),
                          const SizedBox(height: 8),
                          // 10 Characters Grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: MalayalamAlias.all.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 0.85,
                            ),
                            itemBuilder: (context, idx) {
                              final alias = MalayalamAlias.all[idx];
                              final isSelected = alias.id == _selectedAlias.id;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedAlias = alias),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.tkmPurple.withOpacity(0.3)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected
                                        ? Border.all(color: AppColors.tkmPurple, width: 2)
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AliasAvatar(
                                        alias: alias,
                                        radius: 18,
                                        showBorder: isSelected,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        alias.name.split(' ').first,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? Colors.white : AppColors.darkTextMuted,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 3. Post Type: Tea, Quote, Confession
                  const SizedBox(height: 16),
                  Text(
                    'WHAT ARE YOU SHARING?',
                    style: AppTypography.labelSmall(AppColors.darkTextMuted).copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _typeButton('tea', '🍵 Hot Tea'),
                      const SizedBox(width: 8),
                      _typeButton('quote', '💬 Quote'),
                      const SizedBox(width: 8),
                      _typeButton('confession', '🤫 Confession'),
                    ],
                  ),

                  // 4. Headline / Topic
                  const SizedBox(height: 14),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Topic / Headline (Optional)',
                      hintText: 'e.g. Canteen parotta update, Amphi mystery...',
                    ),
                  ),

                  // 5. Main Content / Scoop
                  const SizedBox(height: 14),
                  TextField(
                    controller: _contentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: _postType == 'quote' ? 'The Quote Text *' : 'The Scoop / Details *',
                      hintText: _postType == 'quote'
                          ? '“Enter the memorable quote heard on campus or during lectures...”'
                          : 'Spill the details here. Keep it respectful and fun!',
                    ),
                  ),

                  // 6. Quote Author (if Quote)
                  if (_postType == 'quote') ...[
                    const SizedBox(height: 14),
                    TextField(
                      controller: _quoteAuthorController,
                      decoration: const InputDecoration(
                        labelText: 'Who said it? (Optional)',
                        hintText: 'e.g. S6 Lab Instructor, Overheard at Amphi stairs...',
                      ),
                    ),
                  ],

                  // 7. ImgBB Image Proof Attachment
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.tkmPurple.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.tkmPurple.withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.image_outlined, size: 16, color: AppColors.tkmPurple),
                                const SizedBox(width: 6),
                                Text(
                                  'IMAGE PROOF (IMGBB ONLY)',
                                  style: AppTypography.labelSmall(
                                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ).copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.tkmPurple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'ImgBB Only',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.tkmPurple,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Upload photo proof to ImgBB (free & no account needed), then paste the link here. Auto-converts to direct image proof!',
                          style: TextStyle(fontSize: 10.5, color: AppColors.darkTextMuted, height: 1.3),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => ImgbbResolver.openBrowser('https://imgbb.com'),
                                icon: const Icon(Icons.open_in_new, size: 13),
                                label: const Text('Upload on ImgBB.com', style: TextStyle(fontSize: 10.5)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.tkmPurple,
                                  side: const BorderSide(color: AppColors.tkmPurple),
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _imageController.text = 'https://ibb.co/GvsTj5Nn';
                                  _handleImageUrlChanged('https://ibb.co/GvsTj5Nn');
                                },
                                icon: const Icon(Icons.auto_awesome, size: 13),
                                label: const Text('Sample Link', style: TextStyle(fontSize: 10.5)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.accentTeal,
                                  side: const BorderSide(color: AppColors.accentTeal),
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _imageController,
                          onChanged: _handleImageUrlChanged,
                          decoration: InputDecoration(
                            labelText: 'Paste ImgBB Link (ibb.co/...)',
                            hintText: 'https://ibb.co/GvsTj5Nn or https://i.ibb.co/...',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            suffixIcon: _isResolvingImgbb
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : (_imageController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 16),
                                        onPressed: () {
                                          _imageController.clear();
                                          _handleImageUrlChanged('');
                                        },
                                      )
                                    : null),
                          ),
                        ),
                        if (_imgbbStatus != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                _imgbbHasError
                                    ? Icons.error_outline
                                    : (_isResolvingImgbb ? Icons.hourglass_top : Icons.check_circle_outline),
                                size: 13,
                                color: _imgbbHasError
                                    ? AppColors.error
                                    : (_isResolvingImgbb ? AppColors.tkmPurple : AppColors.accentTeal),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _imgbbStatus!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _imgbbHasError
                                        ? AppColors.error
                                        : (_isResolvingImgbb ? AppColors.tkmPurple : AppColors.accentTeal),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_imageController.text.trim().isNotEmpty &&
                            !_imgbbHasError &&
                            ImgbbResolver.isDirectImage(_imageController.text.trim())) ...[
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: _imageController.text.trim(),
                              height: 110,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (c, u) => Container(
                                height: 110,
                                color: Colors.black12,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (c, u, e) => Container(
                                height: 60,
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Image preview unavailable',
                                  style: TextStyle(fontSize: 10, color: AppColors.darkTextMuted),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 8. Allow Comments Switch
                  const SizedBox(height: 14),
                  SwitchListTile(
                    value: _allowComments,
                    onChanged: (val) => setState(() => _allowComments = val),
                    title: const Text('Allow Comments from Campus', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text(
                      'Turn OFF if you don’t want replies on this post',
                      style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                    ),
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.tkmPurple,
                  ),

                  // 9. Submit Button
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tkmPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Spill Tea to Campus', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeButton(String type, String label) {
    final isSelected = _postType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _postType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.tkmPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.tkmPurple : AppColors.darkTextMuted.withOpacity(0.4),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.darkTextMuted,
            ),
          ),
        ),
      ),
    );
  }
}
