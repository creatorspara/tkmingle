import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

class DiscoveryFilters {
  final String department;
  final String academicYear;
  final String interest;
  final String searchQuery;
  final bool onlyAvailable;
  final bool recentlyJoined;

  const DiscoveryFilters({
    this.department = 'All',
    this.academicYear = 'All',
    this.interest = 'All',
    this.searchQuery = '',
    this.onlyAvailable = false,
    this.recentlyJoined = false,
  });

  DiscoveryFilters copyWith({
    String? department,
    String? academicYear,
    String? interest,
    String? searchQuery,
    bool? onlyAvailable,
    bool? recentlyJoined,
  }) {
    return DiscoveryFilters(
      department: department ?? this.department,
      academicYear: academicYear ?? this.academicYear,
      interest: interest ?? this.interest,
      searchQuery: searchQuery ?? this.searchQuery,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
      recentlyJoined: recentlyJoined ?? this.recentlyJoined,
    );
  }
}

final discoveryFiltersProvider = StateProvider<DiscoveryFilters>((ref) {
  return const DiscoveryFilters();
});

class DiscoveryNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final UserRepository _userRepo;
  final Ref _ref;
  final Set<String> _skippedUids = {};
  final Set<String> _savedUids = {};

  DiscoveryNotifier(this._userRepo, this._ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  Set<String> get savedUids => Set.unmodifiable(_savedUids);

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final currentUser = _ref.read(authProvider).value;
      final filters = _ref.read(discoveryFiltersProvider);

      final list = await _userRepo.getDiscoverableStudents(
        currentUserId: currentUser?.uid,
        departmentFilter: filters.department == 'All' ? null : filters.department,
        yearFilter: filters.academicYear == 'All' ? null : filters.academicYear,
        interestFilter: filters.interest == 'All' ? null : filters.interest,
        searchQuery: filters.searchQuery,
        onlyAvailable: filters.onlyAvailable,
      );

      // Filter out skipped profiles in this session
      final filtered = list.where((u) => !_skippedUids.contains(u.uid)).toList();
      state = AsyncValue.data(filtered);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void skipStudent(String uid) {
    _skippedUids.add(uid);
    state.whenData((students) {
      state = AsyncValue.data(students.where((s) => s.uid != uid).toList());
    });
  }

  void toggleSaveStudent(String uid) {
    if (_savedUids.contains(uid)) {
      _savedUids.remove(uid);
    } else {
      _savedUids.add(uid);
    }
  }

  bool isSaved(String uid) => _savedUids.contains(uid);

  void resetSkipped() {
    _skippedUids.clear();
    refresh();
  }
}

final discoveryProvider = StateNotifierProvider<DiscoveryNotifier, AsyncValue<List<UserModel>>>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return DiscoveryNotifier(userRepo, ref);
});
