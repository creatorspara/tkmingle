import 'user_model.dart';

class ConnectionModel {
  final String id;
  final List<String> userIds;
  final DateTime createdAt;
  final UserModel? otherUser;

  ConnectionModel({
    required this.id,
    required this.userIds,
    DateTime? createdAt,
    this.otherUser,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userIds': userIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ConnectionModel.fromJson(Map<String, dynamic> json, {UserModel? otherUser}) {
    return ConnectionModel(
      id: json['id'] as String,
      userIds: List<String>.from(json['userIds'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      otherUser: otherUser,
    );
  }
}
