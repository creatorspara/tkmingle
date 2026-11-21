import 'user_model.dart';

class ConversationModel {
  final String conversationId;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final UserModel? otherUser;
  final bool isTyping;

  ConversationModel({
    required this.conversationId,
    required this.participants,
    required this.lastMessage,
    DateTime? lastMessageAt,
    this.unreadCount = 0,
    this.otherUser,
    this.isTyping = false,
  }) : lastMessageAt = lastMessageAt ?? DateTime.now();

  ConversationModel copyWith({
    String? conversationId,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    UserModel? otherUser,
    bool? isTyping,
  }) {
    return ConversationModel(
      conversationId: conversationId ?? this.conversationId,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      otherUser: otherUser ?? this.otherUser,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json, {UserModel? otherUser}) {
    return ConversationModel(
      conversationId: json['conversationId'] as String,
      participants: List<String>.from(json['participants'] ?? []),
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'] as String)
          : DateTime.now(),
      unreadCount: json['unreadCount'] as int? ?? 0,
      otherUser: otherUser,
    );
  }
}
