import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/supabase_user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  if (AppConstants.isSupabaseConfigured) {
    return SupabaseUserRepository();
  }
  return LocalUserRepository();
});

final userProfileProvider = FutureProvider.family<UserModel?, String>((ref, uid) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getUserById(uid);
});

final surpriseStudentProvider = FutureProvider.family<UserModel, String>((ref, currentUserId) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getRandomEligibleStudent(currentUserId);
});
