import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/conversation_model.dart';
import '../data/models/message_model.dart';
import '../data/repositories/message_repository.dart';
import 'user_provider.dart';
import 'auth_provider.dart';

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return LocalMessageRepository(userRepository: userRepo);
});

final conversationsProvider = FutureProvider<List<ConversationModel>>((ref) async {
  final repo = ref.watch(messageRepositoryProvider);
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  return repo.getConversations(user.uid);
});

final messagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, conversationId) {
  final repo = ref.watch(messageRepositoryProvider);
  return repo.streamMessages(conversationId);
});
