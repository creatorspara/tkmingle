import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/tea_post_model.dart';
import '../data/repositories/tea_repository.dart';
import 'auth_provider.dart';

final teaRepositoryProvider = Provider<TeaRepository>((ref) {
  return TeaRepository();
});

class TeaFeedNotifier extends StateNotifier<AsyncValue<List<TeaPost>>> {
  final TeaRepository _repository;
  final Ref _ref;

  TeaFeedNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadPosts();
  }

  Future<void> loadPosts() async {
    try {
      final posts = await _repository.getTeaPosts();
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleReaction(String postId, {required bool isFire}) async {
    final current = state.value;
    if (current == null) return;
    final user = _ref.read(authProvider).value;

    final updated = current.map((p) {
      if (p.id != postId) return p;
      if (isFire) {
        final nextFired = !p.isFired;
        final newFires = nextFired ? p.firesCount + 1 : (p.firesCount > 0 ? p.firesCount - 1 : 0);
        _repository.updateReactionState(
          postId: postId,
          isFire: true,
          isActive: nextFired,
          likesCount: p.likesCount,
          firesCount: newFires,
          userId: user?.uid,
        );
        return p.copyWith(firesCount: newFires, isFired: nextFired);
      } else {
        final nextLiked = !p.isLiked;
        final newLikes = nextLiked ? p.likesCount + 1 : (p.likesCount > 0 ? p.likesCount - 1 : 0);
        _repository.updateReactionState(
          postId: postId,
          isFire: false,
          isActive: nextLiked,
          likesCount: newLikes,
          firesCount: p.firesCount,
          userId: user?.uid,
        );
        return p.copyWith(likesCount: newLikes, isLiked: nextLiked);
      }
    }).toList();

    state = AsyncValue.data(updated);
  }

  Future<void> toggleAllowComments(String postId) async {
    final current = state.value;
    if (current == null) return;
    final user = _ref.read(authProvider).value;

    final targetPost = current.where((p) => p.id == postId).firstOrNull;
    if (targetPost == null) return;

    // Security check: strictly restrict comments toggle to the post author
    if (targetPost.userId != null && (user == null || user.uid != targetPost.userId)) {
      debugPrint("Access Denied: only the post author can toggle comments on $postId.");
      return;
    }

    final updated = current.map((p) {
      if (p.id != postId) return p;
      final nextVal = !p.allowComments;
      _repository.toggleComments(postId, nextVal, userId: user?.uid);
      return p.copyWith(allowComments: nextVal);
    }).toList();

    state = AsyncValue.data(updated);
  }

  Future<void> addComment(
    String postId,
    String text, {
    required bool isAnonymous,
    MalayalamAlias? selectedAlias,
  }) async {
    final current = state.value;
    if (current == null) return;

    final user = _ref.read(authProvider).value;
    final alias = selectedAlias ?? (MalayalamAlias.all..shuffle()).first;

    final newComment = TeaComment(
      id: 'comm-${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      authorType: isAnonymous ? 'anonymous' : 'profiled',
      authorName: isAnonymous ? alias.name : (user?.name ?? 'TKM Student'),
      authorAvatar: isAnonymous ? null : user?.profileImage,
      authorAlias: isAnonymous ? alias.name : null,
      authorIcon: isAnonymous ? alias.iconUrl : null,
      content: text.trim(),
      createdAt: DateTime.now(),
    );

    // 1. Optimistic UI update: instantly render comment in APK feed
    final updated = current.map((p) {
      if (p.id != postId) return p;
      return p.copyWith(comments: [...p.comments, newComment]);
    }).toList();

    state = AsyncValue.data(updated);

    // 2. Persist to backend without breaking local UI
    try {
      final validUserId = (isAnonymous || user == null) ? null : user.uid;
      await _repository.addComment(newComment, userId: validUserId);
    } catch (e) {
      debugPrint('Error inserting tea comment to remote Supabase: $e');
    }
  }

  Future<void> reportPost({
    required String postId,
    required String reason,
    String? details,
  }) async {
    final current = state.value;
    final post = current?.where((p) => p.id == postId).firstOrNull;
    final user = _ref.read(authProvider).value;

    await _repository.reportPost(
      postId: postId,
      reason: reason,
      details: details,
      reporterId: user?.uid,
      reporterName: user?.name ?? 'TKM Student',
      postSnippet: post != null
          ? (post.title != null ? '${post.title}: ${post.content}' : post.content)
          : null,
      authorAlias: post?.anonymousAlias ?? post?.authorName,
    );
  }

  Future<void> createPost({
    required String type,
    required bool isAnonymous,
    required MalayalamAlias selectedAlias,
    String? title,
    required String content,
    String? quoteAuthor,
    String? imageUrl,
    String department = 'Campus-wide',
    bool allowComments = true,
  }) async {
    final user = _ref.read(authProvider).value;

    final newPost = TeaPost(
      id: 'tea-${DateTime.now().millisecondsSinceEpoch}',
      userId: user?.uid,
      type: type,
      authorType: isAnonymous ? 'anonymous' : 'profiled',
      authorName: isAnonymous ? 'Anonymous Student' : (user?.name ?? 'TKM Student'),
      authorUsername: isAnonymous ? null : (user?.email.split('@').first ?? 'student'),
      authorDept: isAnonymous ? null : (user?.department ?? 'Engineering'),
      authorAvatar: isAnonymous ? null : user?.profileImage,
      anonymousAlias: isAnonymous ? selectedAlias.name : null,
      anonymousTag: isAnonymous ? 'Anonymous • ${selectedAlias.name}' : null,
      anonymousIcon: isAnonymous ? selectedAlias.iconUrl : null,
      title: title?.trim().isNotEmpty == true ? title!.trim() : null,
      content: content.trim(),
      quoteAuthor: type == 'quote'
          ? (quoteAuthor?.trim().isNotEmpty == true ? quoteAuthor!.trim() : 'Heard on Campus')
          : null,
      imageUrl: imageUrl?.trim().isNotEmpty == true ? imageUrl!.trim() : null,
      department: department,
      likesCount: 1,
      firesCount: 0,
      allowComments: allowComments,
      comments: const [],
      createdAt: DateTime.now(),
      isLiked: true,
    );

    await _repository.createPost(newPost, userId: user?.uid);

    final current = state.value ?? [];
    state = AsyncValue.data([newPost, ...current]);
  }
}

final teaFeedProvider =
    StateNotifierProvider<TeaFeedNotifier, AsyncValue<List<TeaPost>>>((ref) {
  final repo = ref.watch(teaRepositoryProvider);
  return TeaFeedNotifier(repo, ref);
});
