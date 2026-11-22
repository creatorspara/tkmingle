import 'user_model.dart';

enum ConnectionStatus { pending, accepted, declined, cancelled }

class ConnectionRequestModel {
  final String id;
  final String senderId;
  final String receiverId;
  final ConnectionStatus status;
  final DateTime createdAt;
  final UserModel? sender;
  final UserModel? receiver;

  ConnectionRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.status = ConnectionStatus.pending,
    DateTime? createdAt,
    this.sender,
    this.receiver,
  }) : createdAt = createdAt ?? DateTime.now();

  ConnectionRequestModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    ConnectionStatus? status,
    DateTime? createdAt,
    UserModel? sender,
    UserModel? receiver,
  }) {
    return ConnectionRequestModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ConnectionRequestModel.fromJson(Map<String, dynamic> json, {UserModel? sender, UserModel? receiver}) {
    final sId = (json['sender_id'] ?? json['senderId'] ?? '') as String;
    final rId = (json['receiver_id'] ?? json['receiverId'] ?? '') as String;
    final rawDate = json['created_at'] ?? json['createdAt'];
    return ConnectionRequestModel(
      id: json['id'] as String,
      senderId: sId,
      receiverId: rId,
      status: ConnectionStatus.values.byName(json['status'] as String? ?? 'pending'),
      createdAt: rawDate != null
          ? DateTime.parse(rawDate as String)
          : DateTime.now(),
      sender: sender,
      receiver: receiver,
    );
  }
}
