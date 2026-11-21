import 'dart:async';
import '../models/connection_request_model.dart';
import '../models/connection_model.dart';
import 'user_repository.dart';

abstract class ConnectionRepository {
  Future<List<ConnectionRequestModel>> getReceivedRequests(String userId);
  Future<List<ConnectionRequestModel>> getSentRequests(String userId);
  Future<List<ConnectionModel>> getConnections(String userId);
  Future<ConnectionRequestModel> sendRequest(String senderId, String receiverId);
  Future<void> acceptRequest(String requestId);
  Future<void> declineRequest(String requestId);
  Future<void> cancelRequest(String requestId);
  Future<void> removeConnection(String connectionId);
  Future<String> getConnectionState(String currentUserId, String targetUserId);
}

class LocalConnectionRepository implements ConnectionRepository {
  final UserRepository userRepository;
  final List<ConnectionRequestModel> _requests = [];
  final List<ConnectionModel> _connections = [];

  LocalConnectionRepository({required this.userRepository}) {
    // Seed an initial mutual connection between current user and Ananya
    _connections.add(
      ConnectionModel(
        id: 'conn_initial_1',
        userIds: ['user_current', 'user_ananya'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    );

    // Seed a pending received request from Rahul
    _requests.add(
      ConnectionRequestModel(
        id: 'req_seed_1',
        senderId: 'user_rahul',
        receiverId: 'user_current',
        status: ConnectionStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    );

    // Seed a sent request to Meera
    _requests.add(
      ConnectionRequestModel(
        id: 'req_seed_2',
        senderId: 'user_current',
        receiverId: 'user_meera',
        status: ConnectionStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    );
  }

  @override
  Future<List<ConnectionRequestModel>> getReceivedRequests(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final pending = _requests.where((r) => r.receiverId == userId && r.status == ConnectionStatus.pending).toList();
    
    final List<ConnectionRequestModel> populated = [];
    for (final req in pending) {
      final sender = await userRepository.getUserById(req.senderId);
      populated.add(req.copyWith(sender: sender));
    }
    return populated;
  }

  @override
  Future<List<ConnectionRequestModel>> getSentRequests(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final pending = _requests.where((r) => r.senderId == userId && r.status == ConnectionStatus.pending).toList();
    
    final List<ConnectionRequestModel> populated = [];
    for (final req in pending) {
      final receiver = await userRepository.getUserById(req.receiverId);
      populated.add(req.copyWith(receiver: receiver));
    }
    return populated;
  }

  @override
  Future<List<ConnectionModel>> getConnections(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final matches = _connections.where((c) => c.userIds.contains(userId)).toList();
    
    final List<ConnectionModel> populated = [];
    for (final conn in matches) {
      final otherId = conn.userIds.firstWhere((id) => id != userId);
      final other = await userRepository.getUserById(otherId);
      populated.add(ConnectionModel(
        id: conn.id,
        userIds: conn.userIds,
        createdAt: conn.createdAt,
        otherUser: other,
      ));
    }
    return populated;
  }

  @override
  Future<ConnectionRequestModel> sendRequest(String senderId, String receiverId) async {
    // Check if already connected or pending
    final existing = _requests.where((r) =>
        ((r.senderId == senderId && r.receiverId == receiverId) ||
         (r.senderId == receiverId && r.receiverId == senderId)) &&
        r.status == ConnectionStatus.pending).toList();

    if (existing.isNotEmpty) {
      return existing.first;
    }

    final newReq = ConnectionRequestModel(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      receiverId: receiverId,
      status: ConnectionStatus.pending,
    );
    _requests.add(newReq);
    final receiver = await userRepository.getUserById(receiverId);
    return newReq.copyWith(receiver: receiver);
  }

  @override
  Future<void> acceptRequest(String requestId) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final req = _requests[index];
      _requests[index] = req.copyWith(status: ConnectionStatus.accepted);

      // Create mutual connection
      final conn = ConnectionModel(
        id: 'conn_${DateTime.now().millisecondsSinceEpoch}',
        userIds: [req.senderId, req.receiverId],
      );
      _connections.add(conn);
    }
  }

  @override
  Future<void> declineRequest(String requestId) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(status: ConnectionStatus.declined);
    }
  }

  @override
  Future<void> cancelRequest(String requestId) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(status: ConnectionStatus.cancelled);
    }
  }

  @override
  Future<void> removeConnection(String connectionId) async {
    _connections.removeWhere((c) => c.id == connectionId);
  }

  @override
  Future<String> getConnectionState(String currentUserId, String targetUserId) async {
    final isConnected = _connections.any((c) => c.userIds.contains(currentUserId) && c.userIds.contains(targetUserId));
    if (isConnected) return 'connected';

    final sent = _requests.any((r) => r.senderId == currentUserId && r.receiverId == targetUserId && r.status == ConnectionStatus.pending);
    if (sent) return 'pending_sent';

    final received = _requests.any((r) => r.senderId == targetUserId && r.receiverId == currentUserId && r.status == ConnectionStatus.pending);
    if (received) return 'pending_received';

    return 'none';
  }
}
