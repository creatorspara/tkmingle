import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/supabase_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConstants.isSupabaseConfigured) {
    return SupabaseAuthRepository();
  }
  return LocalAuthRepository();
});

class AuthStateNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repository;

  AuthStateNotifier(this._repository) : super(const AsyncValue.loading()) {
    init();
  }

  Future<void> init() async {
    try {
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String department,
    required String academicYear,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.register(
        name: name,
        email: email,
        password: password,
        department: department,
        academicYear: academicYear,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<bool> verifyEmailOtp(String otp) async {
    final current = state.value;
    if (current == null) return false;
    final success = await _repository.verifyEmailOtp(current.email, otp);
    if (success) {
      state = AsyncValue.data(current.copyWith(verified: true));
    }
    return success;
  }

  Future<void> updateProfile(UserModel updated) async {
    await _repository.updateCurrentUser(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> switchUser(UserModel user) async {
    await _repository.updateCurrentUser(user);
    state = AsyncValue.data(user);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}

final authProvider = StateNotifierProvider<AuthStateNotifier, AsyncValue<UserModel?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(repo);
});
