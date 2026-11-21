import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
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
