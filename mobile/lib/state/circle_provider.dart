import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/circle_model.dart';
import '../data/models/post_model.dart';
import '../data/repositories/circle_repository.dart';
import 'auth_provider.dart';

final circleRepositoryProvider = Provider<CircleRepository>((ref) {
  return LocalCircleRepository();
});

final circleCategoryFilterProvider = StateProvider<String>((ref) => 'All');
final circleSearchProvider = StateProvider<String>((ref) => '');

final circlesListProvider = FutureProvider<List<CircleModel>>((ref) async {
  final repo = ref.watch(circleRepositoryProvider);
  final cat = ref.watch(circleCategoryFilterProvider);
  final query = ref.watch(circleSearchProvider);
  return repo.getCircles(category: cat == 'All' ? null : cat, search: query);
});

final joinedCirclesProvider = FutureProvider<List<CircleModel>>((ref) async {
  final repo = ref.watch(circleRepositoryProvider);
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  return repo.getJoinedCircles(user.uid);
});

final circleDetailProvider = FutureProvider.family<CircleModel?, String>((ref, circleId) async {
  final repo = ref.watch(circleRepositoryProvider);
  return repo.getCircleById(circleId);
});

final circlePostsProvider = FutureProvider.family<List<PostModel>, String>((ref, circleId) async {
  final repo = ref.watch(circleRepositoryProvider);
  return repo.getPostsForCircle(circleId);
});

final postDetailProvider = FutureProvider.family<PostModel?, String>((ref, postId) async {
  final repo = ref.watch(circleRepositoryProvider);
  return repo.getPostById(postId);
});
