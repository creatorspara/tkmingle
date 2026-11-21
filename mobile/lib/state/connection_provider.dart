import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/connection_request_model.dart';
import '../data/models/connection_model.dart';
import '../data/repositories/connection_repository.dart';
import 'user_provider.dart';
import 'auth_provider.dart';

final connectionRepositoryProvider = Provider<ConnectionRepository>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return LocalConnectionRepository(userRepository: userRepo);
});

final receivedRequestsProvider = FutureProvider<List<ConnectionRequestModel>>((ref) async {
  final repo = ref.watch(connectionRepositoryProvider);
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  return repo.getReceivedRequests(user.uid);
});

final sentRequestsProvider = FutureProvider<List<ConnectionRequestModel>>((ref) async {
  final repo = ref.watch(connectionRepositoryProvider);
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  return repo.getSentRequests(user.uid);
});

final myConnectionsProvider = FutureProvider<List<ConnectionModel>>((ref) async {
  final repo = ref.watch(connectionRepositoryProvider);
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  return repo.getConnections(user.uid);
});

final connectionStatusProvider = FutureProvider.family<String, String>((ref, targetUserId) async {
  final repo = ref.watch(connectionRepositoryProvider);
  final user = ref.watch(authProvider).value;
  if (user == null) return 'none';
  return repo.getConnectionState(user.uid, targetUserId);
});
