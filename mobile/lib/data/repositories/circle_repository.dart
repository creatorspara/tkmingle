import '../models/circle_model.dart';
import '../models/post_model.dart';
import '../mock/seed_data.dart';

abstract class CircleRepository {
  Future<List<CircleModel>> getCircles({String? category, String? search});
  Future<List<CircleModel>> getJoinedCircles(String userId);
  Future<CircleModel?> getCircleById(String circleId);
  Future<void> joinCircle(String circleId, String userId);
  Future<void> leaveCircle(String circleId, String userId);
  Future<CircleModel> createCircle({
    required String name,
    required String description,
    required String category,
    required String icon,
    required String createdBy,
  });
  Future<List<PostModel>> getPostsForCircle(String circleId);
  Future<PostModel?> getPostById(String postId);
  Future<PostModel> createPost({
    required String circleId,
    required String circleName,
    required String authorId,
    required String authorName,
    required String authorDept,
    required String authorImage,
    required String content,
  });
  Future<void> toggleLikePost(String postId);
  Future<PostComment> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String authorDept,
    required String content,
  });
  Future<List<CircleModel>> getAllCirclesForAdmin();
  Future<void> approveCircle(String circleId, bool approve);
}

class LocalCircleRepository implements CircleRepository {
  final List<CircleModel> _circles = List.from(SeedData.sampleCircles);
  final List<PostModel> _posts = List.from(SeedData.samplePosts);
  final Map<String, Set<String>> _circleMembers = {
    'circle_tech_ai': {'user_current', 'user_ananya', 'user_aditya'},
    'circle_football': {'user_current', 'user_rahul', 'user_gautham'},
    'circle_music': {'user_current', 'user_devika'},
  };

  @override
  Future<List<CircleModel>> getCircles({String? category, String? search}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _circles.where((c) {
      if (!c.isApproved) return false;
      if (category != null && category.isNotEmpty && category != 'All' && c.category != category) {
        return false;
      }
      if (search != null && search.trim().isNotEmpty) {
        final q = search.trim().toLowerCase();
        final matchesName = c.name.toLowerCase().contains(q);
        final matchesDesc = c.description.toLowerCase().contains(q);
        if (!matchesName && !matchesDesc) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<List<CircleModel>> getJoinedCircles(String userId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final joinedIds = _circleMembers.entries
        .where((e) => e.value.contains(userId))
        .map((e) => e.key)
        .toSet();

    return _circles.where((c) => joinedIds.contains(c.circleId)).map((c) => c.copyWith(isMember: true)).toList();
  }

  @override
  Future<CircleModel?> getCircleById(String circleId) async {
    try {
      return _circles.firstWhere((c) => c.circleId == circleId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> joinCircle(String circleId, String userId) async {
    _circleMembers.putIfAbsent(circleId, () => <String>{}).add(userId);
    final index = _circles.indexWhere((c) => c.circleId == circleId);
    if (index != -1) {
      _circles[index] = _circles[index].copyWith(
        memberCount: _circles[index].memberCount + 1,
        isMember: true,
      );
    }
  }

  @override
  Future<void> leaveCircle(String circleId, String userId) async {
    _circleMembers[circleId]?.remove(userId);
    final index = _circles.indexWhere((c) => c.circleId == circleId);
    if (index != -1) {
      _circles[index] = _circles[index].copyWith(
        memberCount: (_circles[index].memberCount - 1).clamp(0, 99999),
        isMember: false,
      );
    }
  }

  @override
  Future<CircleModel> createCircle({
    required String name,
    required String description,
    required String category,
    required String icon,
    required String createdBy,
  }) async {
    final newCircle = CircleModel(
      circleId: 'circle_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      description: description.trim(),
      category: category,
      icon: icon.isEmpty ? '👥' : icon,
      createdBy: createdBy,
      memberCount: 1,
      isApproved: true, // auto-approve in demo/dev mode
      isMember: true,
    );
    _circles.add(newCircle);
    _circleMembers.putIfAbsent(newCircle.circleId, () => <String>{}).add(createdBy);
    return newCircle;
  }

  @override
  Future<List<PostModel>> getPostsForCircle(String circleId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _posts.where((p) => p.circleId == circleId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<PostModel?> getPostById(String postId) async {
    try {
      return _posts.firstWhere((p) => p.postId == postId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PostModel> createPost({
    required String circleId,
    required String circleName,
    required String authorId,
    required String authorName,
    required String authorDept,
    required String authorImage,
    required String content,
  }) async {
    final newPost = PostModel(
      postId: 'post_${DateTime.now().millisecondsSinceEpoch}',
      circleId: circleId,
      circleName: circleName,
      authorId: authorId,
      authorName: authorName,
      authorDept: authorDept,
      authorImage: authorImage,
      content: content.trim(),
      likesCount: 0,
      isLiked: false,
      commentsCount: 0,
      comments: [],
    );
    _posts.insert(0, newPost);
    return newPost;
  }

  @override
  Future<void> toggleLikePost(String postId) async {
    final index = _posts.indexWhere((p) => p.postId == postId);
    if (index != -1) {
      final post = _posts[index];
      final newLiked = !post.isLiked;
      final newLikes = newLiked ? post.likesCount + 1 : (post.likesCount - 1).clamp(0, 9999);
      _posts[index] = post.copyWith(isLiked: newLiked, likesCount: newLikes);
    }
  }

  @override
  Future<PostComment> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String authorDept,
    required String content,
  }) async {
    final newComment = PostComment(
      commentId: 'c_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      authorDept: authorDept,
      content: content.trim(),
    );

    final index = _posts.indexWhere((p) => p.postId == postId);
    if (index != -1) {
      final post = _posts[index];
      final updatedComments = List<PostComment>.from(post.comments)..add(newComment);
      _posts[index] = post.copyWith(
        comments: updatedComments,
        commentsCount: post.commentsCount + 1,
      );
    }
    return newComment;
  }

  @override
  Future<List<CircleModel>> getAllCirclesForAdmin() async {
    return List.unmodifiable(_circles);
  }

  @override
  Future<void> approveCircle(String circleId, bool approve) async {
    final index = _circles.indexWhere((c) => c.circleId == circleId);
    if (index != -1) {
      _circles[index] = _circles[index].copyWith(isApproved: approve);
    }
  }
}
