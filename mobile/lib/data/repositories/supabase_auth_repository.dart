import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final res = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (res != null) {
        return UserModel(
          uid: res['id'] as String,
          name: res['full_name'] as String? ?? 'Student',
          email: res['email'] as String? ?? user.email ?? '',
          department: res['department'] as String? ?? 'General',
          academicYear: res['academic_year'] as String? ?? '1st Year',
          bio: res['bio'] as String? ?? '',
          profileImage: res['profile_image'] as String? ?? '',
          interests: List<String>.from(res['interests'] ?? []),
          skills: List<String>.from(res['skills'] ?? []),
          languages: List<String>.from(res['languages'] ?? []),
          socialAvailability: res['availability'] as String? ?? 'Available to mingle',
          discoverable: res['discoverable'] as bool? ?? true,
          verified: res['verification_status'] == 'verified',
          verificationMethod: res['verification_method'] as String? ?? 'email_otp',
          role: res['role'] as String? ?? 'student',
        );
      }
    } catch (e) {
      debugPrint('Error fetching current profile: $e');
    }

    return UserModel(
      uid: user.id,
      name: user.userMetadata?['full_name'] ?? 'TKM Student',
      email: user.email ?? '',
      department: user.userMetadata?['department'] ?? 'General',
      academicYear: user.userMetadata?['academic_year'] ?? '1st Year',
      verified: user.emailConfirmedAt != null,
      role: 'student',
    );
  }

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    final user = response.user;
    if (user == null) throw Exception('Authentication failed');

    final profile = await getCurrentUser();
    if (profile != null) return profile;

    return UserModel(
      uid: user.id,
      name: email.split('@').first,
      email: email,
      department: 'Engineering',
      academicYear: '1st Year',
      verified: true,
      role: 'student',
    );
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String department,
    required String academicYear,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': name.trim(),
        'department': department,
        'academic_year': academicYear,
      },
    );

    final user = response.user;
    if (user == null) throw Exception('Registration failed');

    // Create profile row in profiles table
    try {
      final username = '${email.split('@').first.replaceAll('.', '_')}_${user.id.substring(0, 4)}';
      await _client.from('profiles').upsert({
        'id': user.id,
        'full_name': name.trim(),
        'username': username,
        'email': email.trim().toLowerCase(),
        'department': department,
        'academic_year': academicYear,
        'verification_status': 'pending',
        'role': 'student',
      });
    } catch (e) {
      debugPrint('Notice on profile creation trigger: $e');
    }

    return UserModel(
      uid: user.id,
      name: name,
      email: email,
      department: department,
      academicYear: academicYear,
      verified: false,
      role: 'student',
    );
  }

  @override
  Future<bool> verifyEmailOtp(String email, String otp) async {
    try {
      final res = await _client.auth.verifyOTP(
        type: OtpType.signup,
        email: email.trim(),
        token: otp.trim(),
      );
      if (res.session != null) return true;

      // Also try email OTP type
      final resEmail = await _client.auth.verifyOTP(
        type: OtpType.email,
        email: email.trim(),
        token: otp.trim(),
      );
      return resEmail.session != null;
    } catch (e) {
      debugPrint('OTP verification error: $e');
      return false;
    }
  }

  Future<bool> checkEmailConfirmed() async {
    try {
      final res = await _client.auth.refreshSession();
      final user = res.user ?? _client.auth.currentUser;
      return user?.emailConfirmedAt != null;
    } catch (e) {
      debugPrint('Session refresh check notice: $e');
      return false;
    }
  }

  @override
  Future<void> sendEmailOtp(String email) async {
    await _client.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> updateCurrentUser(UserModel user) async {
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
}
