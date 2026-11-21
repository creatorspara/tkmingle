class CircleModel {
  final String circleId;
  final String name;
  final String description;
  final String category;
  final String icon;
  final String createdBy;
  final int memberCount;
  final bool isApproved;
  final DateTime createdAt;
  final bool isMember;

  CircleModel({
    required this.circleId,
    required this.name,
    required this.description,
    required this.category,
    this.icon = '👥',
    required this.createdBy,
    this.memberCount = 1,
    this.isApproved = true,
    DateTime? createdAt,
    this.isMember = false,
  }) : createdAt = createdAt ?? DateTime.now();

  CircleModel copyWith({
    String? circleId,
    String? name,
    String? description,
    String? category,
    String? icon,
    String? createdBy,
    int? memberCount,
    bool? isApproved,
    DateTime? createdAt,
    bool? isMember,
  }) {
    return CircleModel(
      circleId: circleId ?? this.circleId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      createdBy: createdBy ?? this.createdBy,
      memberCount: memberCount ?? this.memberCount,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      isMember: isMember ?? this.isMember,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'circleId': circleId,
      'name': name,
      'description': description,
      'category': category,
      'icon': icon,
      'createdBy': createdBy,
      'memberCount': memberCount,
      'isApproved': isApproved,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CircleModel.fromJson(Map<String, dynamic> json, {bool isMember = false}) {
    return CircleModel(
      circleId: json['circleId'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      icon: json['icon'] as String? ?? '👥',
      createdBy: json['createdBy'] as String? ?? '',
      memberCount: json['memberCount'] as int? ?? 1,
      isApproved: json['isApproved'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isMember: isMember,
    );
  }
}
