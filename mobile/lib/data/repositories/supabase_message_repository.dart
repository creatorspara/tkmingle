import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import 'message_repository.dart';
import 'user_repository.dart';

class SupabaseMessageRepository implements MessageRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final UserRepository userRepository;

  SupabaseMessageRepository({required this.userRepository});

  @override
  Future<List<ConversationModel>> getConversations(String currentUserId) async {
    try {
      // 1. Fetch conversations that the current user belongs to
      final memberRows = await _client
          .from('conversation_members')
          .select('conversation_id, last_read_at')
          .eq('user_id', currentUserId);

      if (memberRows is! List || memberRows.isEmpty) {
        return [];
      }

      final List<String> convIds = memberRows
          .map((r) => r['conversation_id'] as String)
          .toList();

      // 2. Fetch conversation records
      final convRows = await _client
          .from('conversations')
          .select()
          .inFilter('id', convIds)
          .order('last_message_at', ascending: false);

      if (convRows is! List) return [];

      final List<ConversationModel> result = [];

      for (final conv in convRows) {
        final convId = conv['id'] as String;
        final myMember = memberRows.firstWhere((m) => m['conversation_id'] == convId);
        final lastReadAtStr = myMember['last_read_at'] as String?;
        final lastReadAt = lastReadAtStr != null ? DateTime.parse(lastReadAtStr) : DateTime.fromMillisecondsSinceEpoch(0);

        // Fetch other participants
        final members = await _client
            .from('conversation_members')
            .select('user_id')
            .eq('conversation_id', convId);

        final participantIds = (members as List)
            .map((m) => m['user_id'] as String)
            .toList();

        final otherId = participantIds.firstWhere(
          (id) => id != currentUserId,
          orElse: () => '',
        );

        UserModel? otherUser;
        if (otherId.isNotEmpty) {
          otherUser = await userRepository.getUserById(otherId);
        }

        // Count unread messages
        int unreadCount = 0;
        try {
          final countRes = await _client
              .from('messages')
              .select('id')
              .eq('conversation_id', convId)
              .neq('sender_id', currentUserId)
              .gt('created_at', lastReadAt.toIso8601String());
          if (countRes is List) {
            unreadCount = countRes.length;
          }
        } catch (_) {}

        final lastMsgAtStr = conv['last_message_at'] as String?;

        result.add(ConversationModel(
          conversationId: convId,
          participants: participantIds,
          lastMessage: conv['last_message_preview'] as String? ?? '',
          lastMessageAt: lastMsgAtStr != null ? DateTime.parse(lastMsgAtStr) : DateTime.now(),
          unreadCount: unreadCount,
          otherUser: otherUser,
        ));
      }

      return result;
    } catch (e) {
      debugPrint('Error getting conversations from Supabase: $e');
      return [];
    }
  }

  @override
  Future<ConversationModel> getOrCreateConversation(String currentUserId, String otherUserId) async {
    try {
      final convId = await _client.rpc('get_or_create_conversation', params: {
        'p_other_user_id': otherUserId,
      }) as String;

      final otherUser = await userRepository.getUserById(otherUserId);
      return ConversationModel(
        conversationId: convId,
        participants: [currentUserId, otherUserId],
        lastMessage: '',
        lastMessageAt: DateTime.now(),
        unreadCount: 0,
        otherUser: otherUser,
      );
    } catch (e) {
      debugPrint('Error in getOrCreateConversation: $e');
      rethrow;
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final rows = await _client
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      if (rows is! List) return [];

      return rows.map((r) => _mapRowToMessage(r as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error getting messages: $e');
      return [];
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String message,
    MessageType type = MessageType.text,
    String? attachmentUrl,
  }) async {
    final insertData = {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': message,
      'message_type': type.name,
      if (attachmentUrl != null) 'attachment_url': attachmentUrl,
    };

    final row = await _client
        .from('messages')
        .insert(insertData)
        .select()
        .single();

    return _mapRowToMessage(row);
  }

  @override
  Future<void> markAsRead(String conversationId, String currentUserId) async {
    try {
      await _client
          .from('conversation_members')
          .update({'last_read_at': DateTime.now().toIso8601String()})
          .match({'conversation_id': conversationId, 'user_id': currentUserId});
    } catch (e) {
      debugPrint('Error marking conversation as read: $e');
    }
  }

  @override
  Stream<List<MessageModel>> streamMessages(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .map((rows) => rows.map((r) => _mapRowToMessage(r)).toList());
  }

  MessageModel _mapRowToMessage(Map<String, dynamic> r) {
    final typeStr = r['message_type'] as String? ?? 'text';
    MessageType msgType;
    if (typeStr == 'image') {
      msgType = MessageType.image;
    } else if (typeStr == 'icebreaker') {
      msgType = MessageType.icebreaker;
    } else {
      msgType = MessageType.text;
    }

    final createdAtStr = r['created_at'] as String?;
    return MessageModel(
      id: r['id'] as String,
      conversationId: r['conversation_id'] as String,
      senderId: r['sender_id'] as String,
      message: r['content'] as String? ?? '',
      type: msgType,
      timestamp: createdAtStr != null ? DateTime.parse(createdAtStr) : DateTime.now(),
      readStatus: r['read_at'] != null,
      attachmentUrl: r['attachment_url'] as String?,
    );
  }
}
