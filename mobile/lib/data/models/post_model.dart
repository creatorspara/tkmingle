class PostComment {
  final String commentId;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorDept;
  final String content;
  final DateTime createdAt;

  PostComment({
    required this.commentId,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorDept,
    required this.content,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorDept': authorDept,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      commentId: json['commentId'] as String,
      postId: json['postId'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorDept: json['authorDept'] as String? ?? '',
      content: json['content'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

class PostModel {
  final String postId;
  final String circleId;
  final String circleName;
  final String authorId;
  final String authorName;
  final String authorDept;
  final String authorImage;
  final String content;
  final int likesCount;
  final bool isLiked;
  final int commentsCount;
  final List<PostComment> comments;
  final DateTime createdAt;

  PostModel({
    required this.postId,
    required this.circleId,
    required this.circleName,
    required this.authorId,
    required this.authorName,
    required this.authorDept,
    this.authorImage = '',
    required this.content,
    this.likesCount = 0,
    this.isLiked = false,
    this.commentsCount = 0,
    this.comments = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  PostModel copyWith({
    String? postId,
    String? circleId,
    String? circleName,
    String? authorId,
    String? authorName,
    String? authorDept,
    String? authorImage,
    String? content,
    int? likesCount,
    bool? isLiked,
    int? commentsCount,
    List<PostComment>? comments,
    DateTime? createdAt,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      circleId: circleId ?? this.circleId,
      circleName: circleName ?? this.circleName,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorDept: authorDept ?? this.authorDept,
      authorImage: authorImage ?? this.authorImage,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      commentsCount: commentsCount ?? this.commentsCount,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'circleId': circleId,
      'circleName': circleName,
      'authorId': authorId,
      'authorName': authorName,
      'authorDept': authorDept,
      'authorImage': authorImage,
      'content': content,
      'likesCount': likesCount,
      'isLiked': isLiked,
      'commentsCount': commentsCount,
      'comments': comments.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: json['postId'] as String,
      circleId: json['circleId'] as String,
      circleName: json['circleName'] as String? ?? 'General',
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorDept: json['authorDept'] as String? ?? '',
      authorImage: json['authorImage'] as String? ?? '',
      content: json['content'] as String,
      likesCount: json['likesCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      commentsCount: json['commentsCount'] as int? ?? 0,
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((c) => PostComment.fromJson(c as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
