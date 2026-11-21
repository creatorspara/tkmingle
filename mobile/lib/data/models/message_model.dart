enum MessageType { text, image, icebreaker }

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String message;
  final MessageType type;
  final DateTime timestamp;
  final bool readStatus;
  final String? attachmentUrl;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    this.type = MessageType.text,
    DateTime? timestamp,
    this.readStatus = false,
    this.attachmentUrl,
  }) : timestamp = timestamp ?? DateTime.now();

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? message,
    MessageType? type,
    DateTime? timestamp,
    bool? readStatus,
    String? attachmentUrl,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      readStatus: readStatus ?? this.readStatus,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'message': message,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'readStatus': readStatus,
      'attachmentUrl': attachmentUrl,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      message: json['message'] as String? ?? '',
      type: MessageType.values.byName(json['type'] as String? ?? 'text'),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      readStatus: json['readStatus'] as bool? ?? false,
      attachmentUrl: json['attachmentUrl'] as String?,
    );
  }
}
