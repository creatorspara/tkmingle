import 'dart:math';
import '../models/user_model.dart';
import '../models/report_model.dart';
import '../mock/seed_data.dart';

abstract class UserRepository {
  Future<List<UserModel>> getDiscoverableStudents({
    String? currentUserId,
    String? departmentFilter,
    String? yearFilter,
    String? interestFilter,
    String? searchQuery,
    bool onlyAvailable = false,
    bool excludeConnected = true,
  });

  Future<UserModel?> getUserById(String uid);
  Future<UserModel> getRandomEligibleStudent(String currentUserId);
  Future<void> updateUserProfile(UserModel user);
  Future<void> setDiscoverability(String userId, bool enabled);
  Future<void> blockUser(String currentUserId, String targetUserId);
  Future<void> reportUser(ReportModel report);
  Future<List<UserModel>> getAllStudentsForAdmin();
  Future<void> suspendUser(String userId, bool suspend);
  Future<void> verifyUser(String userId);
}

class LocalUserRepository implements UserRepository {
  final List<UserModel> _users = List.from(SeedData.sampleUsers);
  final List<ReportModel> _reports = [];

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
    await Future.delayed(const Duration(milliseconds: 300));

    UserModel? currentUser;
    if (currentUserId != null) {
      try {
        currentUser = _users.firstWhere((u) => u.uid == currentUserId);
      } catch (_) {}
    }

    final blockedIds = currentUser?.blockedUserIds ?? [];

    return _users.where((user) {
      // Exclude self
      if (currentUserId != null && user.uid == currentUserId) return false;
      // Exclude admin role from student discovery cards
      if (user.isAdmin) return false;
      // Exclude suspended
      if (user.isSuspended) return false;
      // Exclude non-discoverable
      if (!user.discoverable) return false;
      // Exclude blocked
      if (blockedIds.contains(user.uid)) return false;

      // Department filter
      if (departmentFilter != null && departmentFilter.isNotEmpty && departmentFilter != 'All') {
        if (departmentFilter == 'Same Department') {
          if (currentUser != null && user.department != currentUser.department) return false;
        } else if (departmentFilter == 'Different Department') {
          if (currentUser != null && user.department == currentUser.department) return false;
        } else if (user.department != departmentFilter) {
          return false;
        }
      }

      // Year filter
      if (yearFilter != null && yearFilter.isNotEmpty && yearFilter != 'All') {
        if (user.academicYear != yearFilter) return false;
      }

      // Interest filter
      if (interestFilter != null && interestFilter.isNotEmpty && interestFilter != 'All') {
        if (!user.interests.contains(interestFilter)) return false;
      }

      // Search Query
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.toLowerCase().trim();
        final matchesName = user.name.toLowerCase().contains(query);
        final matchesDept = user.department.toLowerCase().contains(query);
        final matchesInterest = user.interests.any((i) => i.toLowerCase().contains(query));
        final matchesSkill = user.skills.any((s) => s.toLowerCase().contains(query));
        if (!matchesName && !matchesDept && !matchesInterest && !matchesSkill) return false;
      }

      // Only available
      if (onlyAvailable && (user.socialAvailability.isEmpty)) {
        return false;
      }

      return true;
    }).toList()..shuffle();
  }

  @override
  Future<UserModel?> getUserById(String uid) async {
    try {
      return _users.firstWhere((u) => u.uid == uid);
    } catch (_) {
      return null;
    }
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
    final index = _users.indexWhere((u) => u.uid == user.uid);
    if (index != -1) {
      _users[index] = user;
    } else {
      _users.add(user);
    }
  }

  @override
  Future<void> setDiscoverability(String userId, bool enabled) async {
    final index = _users.indexWhere((u) => u.uid == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(discoverable: enabled);
    }
  }

  @override
  Future<void> blockUser(String currentUserId, String targetUserId) async {
    final index = _users.indexWhere((u) => u.uid == currentUserId);
    if (index != -1) {
      final current = _users[index];
      if (!current.blockedUserIds.contains(targetUserId)) {
        final updatedBlocked = List<String>.from(current.blockedUserIds)..add(targetUserId);
        _users[index] = current.copyWith(blockedUserIds: updatedBlocked);
      }
    }
  }

  @override
  Future<void> reportUser(ReportModel report) async {
    _reports.add(report);
  }

  @override
  Future<List<UserModel>> getAllStudentsForAdmin() async {
    return List.unmodifiable(_users);
  }

  @override
  Future<void> suspendUser(String userId, bool suspend) async {
    final index = _users.indexWhere((u) => u.uid == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(isSuspended: suspend);
    }
  }

  @override
  Future<void> verifyUser(String userId) async {
    final index = _users.indexWhere((u) => u.uid == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(
        verified: true,
        verificationMethod: 'Admin approved campus ID',
      );
    }
  }
}
