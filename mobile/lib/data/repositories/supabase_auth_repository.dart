import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Stream of live authentication state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser ?? _client.auth.currentSession?.user;
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
          name: res['full_name'] as String? ?? user.userMetadata?['full_name'] ?? 'Student',
          email: res['email'] as String? ?? user.email ?? '',
          department: res['department'] as String? ?? user.userMetadata?['department'] ?? 'General',
          academicYear: res['academic_year'] as String? ?? user.userMetadata?['academic_year'] ?? '1st Year',
          bio: res['bio'] as String? ?? '',
          profileImage: res['profile_image'] as String? ?? '',
          interests: List<String>.from(res['interests'] ?? []),
          skills: List<String>.from(res['skills'] ?? []),
          languages: List<String>.from(res['languages'] ?? []),
          socialAvailability: res['availability'] as String? ?? 'Available to mingle',
          discoverable: res['discoverable'] as bool? ?? true,
          verified: res['verification_status'] == 'verified' || user.emailConfirmedAt != null,
          verificationMethod: res['verification_method'] as String? ?? 'email_otp',
          role: res['role'] as String? ?? 'student',
        );
      }
    } catch (e) {
      debugPrint('Error fetching current profile: $e');
    }

    // Self-heal profile row for newly authenticated student if trigger was delayed
    try {
      final defaultName = (user.userMetadata?['full_name'] as String?)?.trim().isNotEmpty == true
          ? user.userMetadata!['full_name'] as String
          : user.email?.split('@').first ?? 'TKM Student';
      final defaultDept = user.userMetadata?['department'] as String? ?? 'General';
      final defaultYear = user.userMetadata?['academic_year'] as String? ?? '1st Year';
      final username = '${user.email?.split('@').first.replaceAll('.', '_') ?? 'user'}_${user.id.substring(0, 4)}';

      await _client.from('profiles').upsert({
        'id': user.id,
        'full_name': defaultName,
        'username': username,
        'email': user.email ?? '',
        'department': defaultDept,
        'academic_year': defaultYear,
        'verification_status': user.emailConfirmedAt != null ? 'verified' : 'pending',
        'role': 'student',
      });
    } catch (e) {
      debugPrint('Notice on profile self-heal: $e');
    }

    return UserModel(
      uid: user.id,
      name: user.userMetadata?['full_name'] ?? user.email?.split('@').first ?? 'TKM Student',
      email: user.email ?? '',
      department: user.userMetadata?['department'] ?? 'General',
      academicYear: user.userMetadata?['academic_year'] ?? '1st Year',
      verified: user.emailConfirmedAt != null,
      role: 'student',
    );
  }

  @override
  Future<UserModel> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      final response = await _client.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Authentication failed. No user record returned.');
      }

      final profile = await getCurrentUser();
      if (profile != null) return profile;

      return UserModel(
        uid: user.id,
        name: user.userMetadata?['full_name'] ?? normalizedEmail.split('@').first,
        email: normalizedEmail,
        department: user.userMetadata?['department'] ?? 'Engineering',
        academicYear: user.userMetadata?['academic_year'] ?? '1st Year',
        verified: user.emailConfirmedAt != null,
        role: 'student',
      );
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials') || e.statusCode == '400') {
        throw const AuthException(
          'Invalid email or password. Please verify your credentials or register a new student account.',
        );
      } else if (msg.contains('email not confirmed')) {
        throw const AuthException(
          'Your college email has not been confirmed yet. Please check your inbox for the verification link.',
        );
      } else {
        throw AuthException(e.message);
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String department,
    required String academicYear,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final trimmedName = name.trim();

    final response = await _client.auth.signUp(
      email: normalizedEmail,
      password: password,
      emailRedirectTo: 'https://tkmingle.vercel.app/verify-email',
      data: {
        'full_name': trimmedName,
        'department': department,
        'academic_year': academicYear,
      },
    );

    final user = response.user;
    if (user == null) throw Exception('Registration failed');

    // Create profile row in profiles table
    try {
      final username = '${normalizedEmail.split('@').first.replaceAll('.', '_')}_${user.id.substring(0, 4)}';
      await _client.from('profiles').upsert({
        'id': user.id,
        'full_name': trimmedName,
        'username': username,
        'email': normalizedEmail,
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
      name: trimmedName,
      email: normalizedEmail,
      department: department,
      academicYear: academicYear,
      verified: false,
      role: 'student',
    );
  }

  @override
  Future<bool> verifyEmailOtp(String email, String otp) async {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      final res = await _client.auth.verifyOTP(
        type: OtpType.signup,
        email: normalizedEmail,
        token: otp.trim(),
      );
      if (res.session != null) return true;

      final resEmail = await _client.auth.verifyOTP(
        type: OtpType.email,
        email: normalizedEmail,
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
      email: email.trim().toLowerCase(),
      emailRedirectTo: 'https://tkmingle.vercel.app/verify-email',
    );
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email.trim().toLowerCase());
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
