import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/connection_request_model.dart';
import '../models/connection_model.dart';
import '../models/user_model.dart';
import 'connection_repository.dart';
import 'user_repository.dart';

class SupabaseConnectionRepository implements ConnectionRepository {
  final SupabaseClient _client;
  final UserRepository userRepository;

  SupabaseConnectionRepository({
    SupabaseClient? client,
    required this.userRepository,
  }) : _client = client ?? Supabase.instance.client;

  @override
  Future<List<ConnectionRequestModel>> getReceivedRequests(String userId) async {
    try {
      final response = await _client
          .from('connection_requests')
          .select('*')
          .eq('receiver_id', userId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      final List<ConnectionRequestModel> requests = [];
      for (final json in (response as List)) {
        final senderId = json['sender_id'] as String;
        UserModel? sender;
        try {
          sender = await userRepository.getUserById(senderId);
        } catch (_) {}
        requests.add(ConnectionRequestModel.fromJson(json, sender: sender));
      }
      return requests;
    } catch (e) {
      debugPrint('Error fetching received requests: $e');
      return [];
    }
  }

  @override
  Future<List<ConnectionRequestModel>> getSentRequests(String userId) async {
    try {
      final response = await _client
          .from('connection_requests')
          .select('*')
          .eq('sender_id', userId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      final List<ConnectionRequestModel> requests = [];
      for (final json in (response as List)) {
        final receiverId = json['receiver_id'] as String;
        UserModel? receiver;
        try {
          receiver = await userRepository.getUserById(receiverId);
        } catch (_) {}
        requests.add(ConnectionRequestModel.fromJson(json, receiver: receiver));
      }
      return requests;
    } catch (e) {
      debugPrint('Error fetching sent requests: $e');
      return [];
    }
  }

  @override
  Future<List<ConnectionModel>> getConnections(String userId) async {
    try {
      final response = await _client
          .from('connections')
          .select('*')
          .or('user_one.eq.$userId,user_two.eq.$userId')
          .order('created_at', ascending: false);

      final List<ConnectionModel> connections = [];
      for (final json in (response as List)) {
        final u1 = json['user_one'] as String;
        final u2 = json['user_two'] as String;
        final otherId = u1 == userId ? u2 : u1;
        UserModel? other;
        try {
          other = await userRepository.getUserById(otherId);
        } catch (_) {}
        connections.add(ConnectionModel.fromJson(json, otherUser: other));
      }
      return connections;
    } catch (e) {
      debugPrint('Error fetching connections: $e');
      return [];
    }
  }

  @override
  Future<ConnectionRequestModel> sendRequest(String senderId, String receiverId) async {
    if (senderId == receiverId) {
      throw Exception('Cannot send a connection request to yourself.');
    }

    // Check if an existing request exists between the two users
    final existing = await _client
        .from('connection_requests')
        .select('*')
        .or('and(sender_id.eq.$senderId,receiver_id.eq.$receiverId),and(sender_id.eq.$receiverId,receiver_id.eq.$senderId)')
        .limit(1)
        .maybeSingle();

    if (existing != null) {
      final status = existing['status'] as String;
      final existingSenderId = existing['sender_id'] as String;

      if (status == 'pending') {
        if (existingSenderId == receiverId) {
          // If the other user already sent a pending request, accept it
          await acceptRequest(existing['id'] as String);
          final receiver = await userRepository.getUserById(receiverId);
          return ConnectionRequestModel.fromJson(existing, receiver: receiver)
              .copyWith(status: ConnectionStatus.accepted);
        }
        final receiver = await userRepository.getUserById(receiverId);
        return ConnectionRequestModel.fromJson(existing, receiver: receiver);
      }

      // Re-activate a previously cancelled or declined request
      final updated = await _client
          .from('connection_requests')
          .update({
            'sender_id': senderId,
            'receiver_id': receiverId,
            'status': 'pending',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', existing['id'] as String)
          .select()
          .single();

      final receiver = await userRepository.getUserById(receiverId);
      return ConnectionRequestModel.fromJson(updated, receiver: receiver);
    }

    // Insert new pending request
    final inserted = await _client
        .from('connection_requests')
        .insert({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'status': 'pending',
        })
        .select()
        .single();

    final receiver = await userRepository.getUserById(receiverId);
    return ConnectionRequestModel.fromJson(inserted, receiver: receiver);
  }

  @override
  Future<void> acceptRequest(String requestId) async {
    await _client.from('connection_requests').update({
      'status': 'accepted',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);
  }

  @override
  Future<void> declineRequest(String requestId) async {
    await _client.from('connection_requests').update({
      'status': 'declined',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);
  }

  @override
  Future<void> cancelRequest(String requestId) async {
    await _client.from('connection_requests').update({
      'status': 'cancelled',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);
  }

  @override
  Future<void> removeConnection(String connectionId) async {
    await _client.from('connections').delete().eq('id', connectionId);
  }

  @override
  Future<String> getConnectionState(String currentUserId, String targetUserId) async {
    if (currentUserId == targetUserId) return 'self';

    try {
      // 1. Check if connected
      final u1 = currentUserId.compareTo(targetUserId) < 0 ? currentUserId : targetUserId;
      final u2 = currentUserId.compareTo(targetUserId) < 0 ? targetUserId : currentUserId;
      final conn = await _client
          .from('connections')
          .select('id')
          .eq('user_one', u1)
          .eq('user_two', u2)
          .maybeSingle();

      if (conn != null) return 'connected';

      // 2. Check pending outgoing request
      final sentReq = await _client
          .from('connection_requests')
          .select('id')
          .eq('sender_id', currentUserId)
          .eq('receiver_id', targetUserId)
          .eq('status', 'pending')
          .maybeSingle();

      if (sentReq != null) return 'pending_sent';

      // 3. Check pending incoming request
      final receivedReq = await _client
          .from('connection_requests')
          .select('id')
          .eq('sender_id', targetUserId)
          .eq('receiver_id', currentUserId)
          .eq('status', 'pending')
          .maybeSingle();

      if (receivedReq != null) return 'pending_received';
    } catch (e) {
      debugPrint('Error getting connection state: $e');
    }

    return 'none';
  }
}
