import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';
import '../core/router/app_router.dart';
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
  StreamSubscription<AuthState>? _authSubscription;

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

    // Subscribe to live auth events from Supabase Auth
    if (_repository is SupabaseAuthRepository) {
      _authSubscription = _repository
          .authStateChanges
          .listen((data) async {
        final event = data.event;
        if (event == AuthChangeEvent.signedOut) {
          state = const AsyncValue.data(null);
        } else if (event == AuthChangeEvent.passwordRecovery) {
          appRouter.go('/reset-password');
        } else if (event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.tokenRefreshed ||
            event == AuthChangeEvent.userUpdated) {
          try {
            final user = await _repository.getCurrentUser();
            state = AsyncValue.data(user);
          } catch (e, st) {
            state = AsyncValue.error(e, st);
          }
        }
      });
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email.trim(), password);
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

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthStateNotifier, AsyncValue<UserModel?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(repo);
});
