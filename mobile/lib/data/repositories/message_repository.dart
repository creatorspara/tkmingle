import 'dart:async';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import 'user_repository.dart';

abstract class MessageRepository {
  Future<List<ConversationModel>> getConversations(String currentUserId);
  Future<ConversationModel> getOrCreateConversation(String currentUserId, String otherUserId);
  Future<List<MessageModel>> getMessages(String conversationId);
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String message,
    MessageType type = MessageType.text,
    String? attachmentUrl,
  });
  Future<void> markAsRead(String conversationId, String currentUserId);
  Stream<List<MessageModel>> streamMessages(String conversationId);
}

class LocalMessageRepository implements MessageRepository {
  final UserRepository userRepository;
  final List<ConversationModel> _conversations = [];
  final Map<String, List<MessageModel>> _messages = {};
  final Map<String, StreamController<List<MessageModel>>> _streamControllers = {};

  LocalMessageRepository({required this.userRepository}) {
    // Seed initial conversation with Ananya
    const convId = 'conv_ananya_current';
    _conversations.add(
      ConversationModel(
        conversationId: convId,
        participants: ['user_current', 'user_ananya'],
        lastMessage: 'Hey! Loved your idea about building Flutter apps for college events.',
        lastMessageAt: DateTime.now().subtract(const Duration(minutes: 20)),
        unreadCount: 1,
      ),
    );

    _messages[convId] = [
      MessageModel(
        id: 'msg_1',
        conversationId: convId,
        senderId: 'user_ananya',
        message: 'Hey Abhiram! Great to connect with someone else passionate about Flutter at TKMCE.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        readStatus: true,
      ),
      MessageModel(
        id: 'msg_2',
        conversationId: convId,
        senderId: 'user_current',
        message: 'Hey Ananya! Absolutely, we need more modern campus projects instead of standard notice boards.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        readStatus: true,
      ),
      MessageModel(
        id: 'msg_3',
        conversationId: convId,
        senderId: 'user_ananya',
        message: 'Hey! Loved your idea about building Flutter apps for college events. Should we catch up around Nescafe corner tomorrow after 4?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        readStatus: false,
      ),
    ];
  }

  @override
  Future<List<ConversationModel>> getConversations(String currentUserId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final userConvs = _conversations.where((c) => c.participants.contains(currentUserId)).toList();

    final List<ConversationModel> populated = [];
    for (final conv in userConvs) {
      final otherId = conv.participants.firstWhere((id) => id != currentUserId);
      final other = await userRepository.getUserById(otherId);
      populated.add(conv.copyWith(otherUser: other));
    }

    populated.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return populated;
  }

  @override
  Future<ConversationModel> getOrCreateConversation(String currentUserId, String otherUserId) async {
    final existing = _conversations.where((c) =>
        c.participants.contains(currentUserId) && c.participants.contains(otherUserId)).toList();

    if (existing.isNotEmpty) {
      final other = await userRepository.getUserById(otherUserId);
      return existing.first.copyWith(otherUser: other);
    }

    final newConvId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
    final other = await userRepository.getUserById(otherUserId);
    final newConv = ConversationModel(
      conversationId: newConvId,
      participants: [currentUserId, otherUserId],
      lastMessage: 'Started conversation',
      lastMessageAt: DateTime.now(),
      unreadCount: 0,
      otherUser: other,
    );
    _conversations.insert(0, newConv);
    _messages[newConvId] = [];
    return newConv;
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.from(_messages[conversationId] ?? []);
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String message,
    MessageType type = MessageType.text,
    String? attachmentUrl,
  }) async {
    final newMsg = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: senderId,
      message: message.trim(),
      type: type,
      timestamp: DateTime.now(),
      readStatus: false,
      attachmentUrl: attachmentUrl,
    );

    _messages.putIfAbsent(conversationId, () => []).add(newMsg);

    // Update conversation last message
    final index = _conversations.indexWhere((c) => c.conversationId == conversationId);
    if (index != -1) {
      _conversations[index] = _conversations[index].copyWith(
        lastMessage: type == MessageType.image ? '📷 Sent a photo' : message.trim(),
        lastMessageAt: DateTime.now(),
      );
    }

    _notifyStream(conversationId);

    // Realistic bot response simulation for demo:
    // If sent to ananya, simulate a friendly campus reply after 2.5 seconds
    final conv = index != -1 ? _conversations[index] : null;
    if (conv != null && conv.participants.contains('user_ananya') && senderId != 'user_ananya') {
      _simulateReply(conversationId, 'user_ananya', message);
    }

    return newMsg;
  }

  void _simulateReply(String conversationId, String replierId, String originalMsg) {
    Future.delayed(const Duration(seconds: 2), () {
      final replies = [
        "Sounds awesome! Let's definitely do that.",
        "Totally agree with you on that point!",
        "Let's catch up near the Central Porch or Nescafe corner.",
        "That's so cool! How long have you been working on it?",
        "Haha yes! TKMCE campus life is full of surprises.",
      ];
      final replyText = replies[DateTime.now().millisecond % replies.length];
      final autoMsg = MessageModel(
        id: 'msg_reply_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: conversationId,
        senderId: replierId,
        message: replyText,
        timestamp: DateTime.now(),
        readStatus: true,
      );
      _messages.putIfAbsent(conversationId, () => []).add(autoMsg);

      final index = _conversations.indexWhere((c) => c.conversationId == conversationId);
      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(
          lastMessage: replyText,
          lastMessageAt: DateTime.now(),
          unreadCount: _conversations[index].unreadCount + 1,
        );
      }
      _notifyStream(conversationId);
    });
  }

  @override
  Future<void> markAsRead(String conversationId, String currentUserId) async {
    final index = _conversations.indexWhere((c) => c.conversationId == conversationId);
    if (index != -1) {
      _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
    }
    final msgs = _messages[conversationId];
    if (msgs != null) {
      for (int i = 0; i < msgs.length; i++) {
        if (msgs[i].senderId != currentUserId) {
          msgs[i] = msgs[i].copyWith(readStatus: true);
        }
      }
    }
  }

  @override
  Stream<List<MessageModel>> streamMessages(String conversationId) {
    final controller = _streamControllers.putIfAbsent(
      conversationId,
      () => StreamController<List<MessageModel>>.broadcast(),
    );
    // Yield current messages immediately
    Future.microtask(() => controller.add(List.from(_messages[conversationId] ?? [])));
    return controller.stream;
  }

  void _notifyStream(String conversationId) {
    final controller = _streamControllers[conversationId];
    if (controller != null && !controller.isClosed) {
      controller.add(List.from(_messages[conversationId] ?? []));
    }
  }
}
