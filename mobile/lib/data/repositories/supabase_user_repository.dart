import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/report_model.dart';
import 'user_repository.dart';

class SupabaseUserRepository implements UserRepository {
  final SupabaseClient _client = Supabase.instance.client;

  UserModel _mapProfileToUser(Map<String, dynamic> row) {
    return UserModel(
      uid: row['id'] as String,
      name: row['full_name'] as String? ?? 'Student',
      email: row['email'] as String? ?? '',
      department: row['department'] as String? ?? 'Engineering',
      academicYear: row['academic_year'] as String? ?? '1st Year',
      bio: row['bio'] as String? ?? '',
      profileImage: row['profile_image'] as String? ?? '',
      interests: List<String>.from(row['interests'] ?? []),
      skills: List<String>.from(row['skills'] ?? []),
      languages: List<String>.from(row['languages'] ?? ['English', 'Malayalam']),
      verified: row['verification_status'] == 'verified',
      verificationMethod: row['verification_method'] as String? ?? 'email_otp',
      discoverable: row['discoverable'] as bool? ?? true,
      socialAvailability: row['availability'] as String? ?? 'Available to mingle',
      role: row['role'] as String? ?? 'student',
    );
  }

  @override
  Future<List<UserModel>> getDiscoverableStudents({
    String? currentUserId,
    String? departmentFilter,
    String? yearFilter,
    String? interestFilter,
    String? searchQuery,
    bool onlyAvailable = false,
    bool excludeConnected = true,
  }) async {
    try {
      var query = _client.from('profiles').select().eq('discoverable', true);

      if (currentUserId != null && currentUserId.isNotEmpty) {
        query = query.neq('id', currentUserId);
      }

      if (departmentFilter != null && departmentFilter.isNotEmpty && departmentFilter != 'All') {
        if (departmentFilter != 'Same Department' && departmentFilter != 'Different Department') {
          query = query.eq('department', departmentFilter);
        }
      }

      if (yearFilter != null && yearFilter.isNotEmpty && yearFilter != 'All') {
        query = query.eq('academic_year', yearFilter);
      }

      final rows = await query;
      if (rows is List && rows.isNotEmpty) {
        var list = rows.map((r) => _mapProfileToUser(r as Map<String, dynamic>)).toList();

        // Exclude admin or suspended accounts
        list = list.where((u) => !u.isAdmin && !u.isSuspended).toList();

        if (searchQuery != null && searchQuery.trim().isNotEmpty) {
          final q = searchQuery.toLowerCase().trim();
          list = list.where((u) =>
            u.name.toLowerCase().contains(q) ||
            u.department.toLowerCase().contains(q) ||
            u.interests.any((i) => i.toLowerCase().contains(q)) ||
            u.skills.any((s) => s.toLowerCase().contains(q))
          ).toList();
        }

        return list;
      }
    } catch (e) {
      debugPrint('Notice on Supabase profiles discovery: $e');
    }

    return [];
  }

  @override
  Future<UserModel?> getUserById(String uid) async {
    try {
      final row = await _client.from('profiles').select().eq('id', uid).maybeSingle();
      if (row != null) {
        return _mapProfileToUser(row);
      }
    } catch (e) {
      debugPrint('Error getting user by id: $e');
    }

    return null;
  }

  @override
  Future<UserModel> getRandomEligibleStudent(String currentUserId) async {
    final eligible = await getDiscoverableStudents(currentUserId: currentUserId);
    if (eligible.isEmpty) {
      throw Exception('No eligible students available at the moment.');
    }
    final rand = Random();
    return eligible[rand.nextInt(eligible.length)];
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    await _client.from('profiles').update({
      'full_name': user.name,
      'department': user.department,
      'academic_year': user.academicYear,
      'bio': user.bio,
      'availability': user.socialAvailability,
      'discoverable': user.discoverable,
      'interests': user.interests,
      'skills': user.skills,
      'languages': user.languages,
    }).eq('id', user.uid);
  }

  @override
  Future<void> setDiscoverability(String userId, bool enabled) async {
    await _client.from('profiles').update({'discoverable': enabled}).eq('id', userId);
  }

  @override
  Future<void> blockUser(String currentUserId, String targetUserId) async {
    // In database, handled via user_blocks table
    try {
      await _client.from('user_blocks').insert({
        'blocker_id': currentUserId,
        'blocked_user_id': targetUserId,
      });
    } catch (e) {
      debugPrint('Block user note: $e');
    }
  }

  @override
  Future<void> reportUser(ReportModel report) async {
    try {
      await _client.from('reports').insert({
        'reporter_id': report.reporterId,
        'reported_user_id': report.reportedUserId,
        'reason': report.reason,
        'details': report.details,
      });
    } catch (e) {
      debugPrint('Report user note: $e');
    }
  }

  @override
  Future<List<UserModel>> getAllStudentsForAdmin() async {
    try {
      final rows = await _client.from('profiles').select();
      if (rows is List && rows.isNotEmpty) {
        return rows.map((r) => _mapProfileToUser(r as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Admin fetch profiles note: $e');
    }
    return _fallbackUsers;
  }

  @override
  Future<void> suspendUser(String userId, bool suspend) async {
    await _client.from('profiles').update({
      'verification_status': suspend ? 'suspended' : 'verified'
    }).eq('id', userId);
  }

  @override
  Future<void> verifyUser(String userId) async {
    await _client.from('profiles').update({
      'verification_status': 'verified'
    }).eq('id', userId);
  }
}
