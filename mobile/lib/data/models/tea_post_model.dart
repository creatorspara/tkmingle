import 'package:flutter/material.dart';

class MalayalamAlias {
  final String id;
  final String name;
  final String iconUrl;
  final String assetPath;
  final Alignment alignment;

  const MalayalamAlias({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.assetPath,
    this.alignment = Alignment.center,
  });

  static const List<MalayalamAlias> all = [
    MalayalamAlias(
      id: 'damu',
      name: 'Dasamoolam Damu',
      iconUrl: 'https://malayalidino.webappbazaar.com/img/damulogo.jpg',
      assetPath: 'assets/avatars/aliases/damu.jpg',
      alignment: Alignment.center,
    ),
    MalayalamAlias(
      id: 'pavanayi',
      name: 'Pavanayi',
      iconUrl: 'https://images.indianexpress.com/2018/09/captain-raju-7591.jpg',
      assetPath: 'assets/avatars/aliases/pavanayi.jpg',
      alignment: Alignment.topCenter,
    ),
    MalayalamAlias(
      id: 'ramanan',
      name: 'Ramanan',
      iconUrl: 'https://mir-s3-cdn-cf.behance.net/projects/404/3fa15995862635.Y3JvcCwxMDgwLDg0NCwwLDExNw.jpg',
      assetPath: 'assets/avatars/aliases/ramanan.jpg',
      alignment: Alignment.center,
    ),
    MalayalamAlias(
      id: 'appukkuttan',
      name: 'Appukkuttan',
      iconUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-1QgEUc0Kk_4wDxwkHOTJtbPJm2blqeP2BU1juLuP6w&s=10',
      assetPath: 'assets/avatars/aliases/appukkuttan.jpg',
      alignment: Alignment.center,
    ),
    MalayalamAlias(
      id: 'gafoor',
      name: 'Gafoor',
      iconUrl: 'https://i.ytimg.com/vi/VWENsLwR00Q/hqdefault.jpg',
      assetPath: 'assets/avatars/aliases/gafoor.jpg',
      alignment: Alignment.center,
    ),
    MalayalamAlias(
      id: 'arakkal_abu',
      name: 'Arakkal Abu',
      iconUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSpix3vrUAyvxgBGAM9aFrwyo5wv4b2vaB6nJp-db-Tre8SlvyA35aN-rL5&s=10',
      assetPath: 'assets/avatars/aliases/arakkal_abu.jpg',
      alignment: Alignment.center,
    ),
    MalayalamAlias(
      id: 'shaji_pappan',
      name: 'Shaji Pappan',
      iconUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTarKvyIzBQnGZLZZuHZQ4bkLyPAeJIcBXnqDTKEMNung7WTn9Wo8UkeFQ&s=10',
      assetPath: 'assets/avatars/aliases/shaji_pappan.jpg',
      alignment: Alignment.center,
    ),
    MalayalamAlias(
      id: 'nagavalli',
      name: 'Nagavalli',
      iconUrl: 'https://mir-s3-cdn-cf.behance.net/project_modules/max_1200_webp/a0004e97160833.5ebe96eff2e5f.jpg',
      assetPath: 'assets/avatars/aliases/nagavalli.webp',
      alignment: Alignment(0.0, -0.6),
    ),
    MalayalamAlias(
      id: 'kumbidi',
      name: 'Kumbidi',
      iconUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKlxTjAe--_NYQq_LhjLrS3QrTOXGeF9VPFcH5exrCg9fkabfZHGbu0rTP&s=10',
      assetPath: 'assets/avatars/aliases/kumbidi.jpg',
      alignment: Alignment.center,
    ),
    MalayalamAlias(
      id: 'manavalan',
      name: 'Manavalan',
      iconUrl: 'https://i.pinimg.com/736x/28/40/dd/2840dd7b53519681c94105e8a5739bf8.jpg',
      assetPath: 'assets/avatars/aliases/manavalan.jpg',
      alignment: Alignment(0.0, -0.64),
    ),
  ];

  static MalayalamAlias findByName(String? name) {
    if (name == null || name.trim().isEmpty) return all[0];
    final clean = name.toLowerCase().trim();
    return all.firstWhere(
      (a) => a.name.toLowerCase() == clean || a.id.toLowerCase() == clean,
      orElse: () => all[0],
    );
  }
}

class TeaComment {
  final String id;
  final String postId;
  final String authorType; // 'anonymous' | 'profiled'
  final String authorName;
  final String? authorAvatar;
  final String? authorAlias;
  final String? authorIcon;
  final String content;
  final DateTime createdAt;

  TeaComment({
    required this.id,
    required this.postId,
    required this.authorType,
    required this.authorName,
    this.authorAvatar,
    this.authorAlias,
    this.authorIcon,
    required this.content,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TeaComment.fromJson(Map<String, dynamic> json) {
    return TeaComment(
      id: json['id']?.toString() ?? '',
      postId: json['post_id']?.toString() ?? '',
      authorType: json['author_type'] as String? ?? 'anonymous',
      authorName: json['author_name'] as String? ?? 'Student',
      authorAvatar: json['author_avatar'] as String?,
      authorAlias: json['anonymous_alias'] as String? ?? json['author_alias'] as String?,
      authorIcon: json['anonymous_icon'] as String? ?? json['author_icon'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'author_type': authorType,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'anonymous_alias': authorAlias,
      'anonymous_icon': authorIcon,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class TeaPost {
  final String id;
  final String? userId;
  final String type; // 'tea' | 'quote' | 'confession' | 'shoutout'
  final String authorType; // 'anonymous' | 'profiled'
  final String authorName;
  final String? authorUsername;
  final String? authorDept;
  final String? authorAvatar;
  final String? anonymousAlias;
  final String? anonymousTag;
  final String? anonymousIcon;
  final String? title;
  final String content;
  final String? quoteAuthor;
  final String? imageUrl;
  final String department;
  final int likesCount;
  final int firesCount;
  final bool allowComments;
  final List<TeaComment> comments;
  final DateTime createdAt;
  final bool isLiked;
  final bool isFired;

  TeaPost({
    required this.id,
    this.userId,
    required this.type,
    required this.authorType,
    required this.authorName,
    this.authorUsername,
    this.authorDept,
    this.authorAvatar,
    this.anonymousAlias,
    this.anonymousTag,
    this.anonymousIcon,
    this.title,
    required this.content,
    this.quoteAuthor,
    this.imageUrl,
    this.department = 'Campus-wide',
    this.likesCount = 0,
    this.firesCount = 0,
    this.allowComments = true,
    this.comments = const [],
    DateTime? createdAt,
    this.isLiked = false,
    this.isFired = false,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isAnonymous => authorType == 'anonymous';

  MalayalamAlias get aliasModel => MalayalamAlias.findByName(anonymousAlias);

  TeaPost copyWith({
    String? id,
    String? userId,
    String? type,
    String? authorType,
    String? authorName,
    String? authorUsername,
    String? authorDept,
    String? authorAvatar,
    String? anonymousAlias,
    String? anonymousTag,
    String? anonymousIcon,
    String? title,
    String? content,
    String? quoteAuthor,
    String? imageUrl,
    String? department,
    int? likesCount,
    int? firesCount,
    bool? allowComments,
    List<TeaComment>? comments,
    DateTime? createdAt,
    bool? isLiked,
    bool? isFired,
  }) {
    return TeaPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      authorType: authorType ?? this.authorType,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      authorDept: authorDept ?? this.authorDept,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      anonymousAlias: anonymousAlias ?? this.anonymousAlias,
      anonymousTag: anonymousTag ?? this.anonymousTag,
      anonymousIcon: anonymousIcon ?? this.anonymousIcon,
      title: title ?? this.title,
      content: content ?? this.content,
      quoteAuthor: quoteAuthor ?? this.quoteAuthor,
      imageUrl: imageUrl ?? this.imageUrl,
      department: department ?? this.department,
      likesCount: likesCount ?? this.likesCount,
      firesCount: firesCount ?? this.firesCount,
      allowComments: allowComments ?? this.allowComments,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
      isFired: isFired ?? this.isFired,
    );
  }

  factory TeaPost.fromJson(Map<String, dynamic> json, {List<TeaComment> comments = const []}) {
    return TeaPost(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] as String?,
      type: json['type'] as String? ?? 'tea',
      authorType: json['author_type'] as String? ?? 'anonymous',
      authorName: json['author_name'] as String? ?? 'Anonymous Student',
      authorUsername: json['author_username'] as String?,
      authorDept: json['author_dept'] as String?,
      authorAvatar: json['author_avatar'] as String?,
      anonymousAlias: json['anonymous_alias'] as String?,
      anonymousTag: json['anonymous_tag'] as String?,
      anonymousIcon: json['anonymous_icon'] as String?,
      title: json['title'] as String?,
      content: json['content'] as String? ?? '',
      quoteAuthor: json['quote_author'] as String?,
      imageUrl: json['image_url'] as String?,
      department: json['department'] as String? ?? 'Campus-wide',
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      firesCount: (json['fires_count'] as num?)?.toInt() ?? 0,
      allowComments: json['allow_comments'] != null ? json['allow_comments'] == true : true,
      comments: comments,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'author_type': authorType,
      'author_name': authorName,
      'author_username': authorUsername,
      'author_dept': authorDept,
      'author_avatar': authorAvatar,
      'anonymous_alias': anonymousAlias,
      'anonymous_tag': anonymousTag,
      'anonymous_icon': anonymousIcon,
      'title': title,
      'content': content,
      'quote_author': quoteAuthor,
      'image_url': imageUrl,
      'department': department,
      'likes_count': likesCount,
      'fires_count': firesCount,
      'allow_comments': allowComments,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
