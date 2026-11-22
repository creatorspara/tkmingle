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
    List<String> ids;
    if (json['userIds'] != null) {
      ids = List<String>.from(json['userIds']);
    } else if (json['user_one'] != null && json['user_two'] != null) {
      ids = [json['user_one'].toString(), json['user_two'].toString()];
    } else {
      ids = [];
    }

    final rawDate = json['created_at'] ?? json['createdAt'];
    return ConnectionModel(
      id: json['id'] as String,
      userIds: ids,
      createdAt: rawDate != null
          ? DateTime.parse(rawDate as String)
          : DateTime.now(),
      otherUser: otherUser,
    );
  }
}
