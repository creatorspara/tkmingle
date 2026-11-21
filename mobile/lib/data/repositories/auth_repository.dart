import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/college_data.dart';
import '../models/user_model.dart';
import '../mock/seed_data.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String department,
    required String academicYear,
  });
  Future<bool> verifyEmailOtp(String email, String otp);
  Future<void> sendEmailOtp(String email);
  Future<void> logout();
  Future<void> resetPassword(String email);
  Future<void> updateCurrentUser(UserModel user);
}

class LocalAuthRepository implements AuthRepository {
  static const String _userKey = AppConstants.prefsAuthUserKey;
  UserModel? _currentUser;
  final List<UserModel> _allUsers = List.from(SeedData.sampleUsers);

  LocalAuthRepository({bool seedInitialUser = true}) {
    if (seedInitialUser) {
      _currentUser = _allUsers.firstWhere((u) => u.uid == 'user_current');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_userKey);
    if (jsonStr != null) {
      _currentUser = UserModel.fromJson(jsonDecode(jsonStr));
      return _currentUser;
    }
    return null;
  }

  @override
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Network simulation
    final cleanEmail = email.trim().toLowerCase();
    
    // Check if user exists in mock or seed data
    final existing = _allUsers.firstWhere(
      (u) => u.email.toLowerCase() == cleanEmail,
      orElse: () {
        // Allow login with demo accounts or any @tkmce.ac.in email
        return UserModel(
          uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
          name: cleanEmail.split('@').first.replaceAll('.', ' ').toUpperCase(),
          email: cleanEmail,
          department: CollegeData.departments.first,
          academicYear: '3rd Year',
          verified: cleanEmail.endsWith('tkmce.ac.in'),
          role: cleanEmail.contains('admin') ? 'admin' : 'student',
        );
      },
    );

    if (existing.isSuspended) {
      throw Exception('This account has been suspended by campus administration.');
    }

    _currentUser = existing;
    await _saveUserToPrefs(existing);
    return existing;
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String department,
    required String academicYear,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final cleanEmail = email.trim().toLowerCase();
    
    final newUser = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: cleanEmail,
      department: department,
      academicYear: academicYear,
      verified: false,
      verificationMethod: 'email_otp',
      discoverable: true,
      role: cleanEmail.contains('admin') ? 'admin' : 'student',
    );

    _allUsers.add(newUser);
    _currentUser = newUser;
    await _saveUserToPrefs(newUser);
    return newUser;
  }

  @override
  Future<void> sendEmailOtp(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // In production: Cloud Function triggers institutional email OTP
  }

  @override
  Future<bool> verifyEmailOtp(String email, String otp) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Any 6-digit OTP (or '123456') verifies for demo/development mode
    if (otp.length == 6) {
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(verified: true);
        await _saveUserToPrefs(_currentUser!);
      }
      return true;
    }
    return false;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> updateCurrentUser(UserModel user) async {
    _currentUser = user;
    final index = _allUsers.indexWhere((u) => u.uid == user.uid);
    if (index != -1) {
      _allUsers[index] = user;
    } else {
      _allUsers.add(user);
    }
    await _saveUserToPrefs(user);
  }

  Future<void> _saveUserToPrefs(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
}
