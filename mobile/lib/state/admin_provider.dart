import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/report_model.dart';
import '../data/repositories/admin_repository.dart';
import 'user_provider.dart';
import 'circle_provider.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  final circleRepo = ref.watch(circleRepositoryProvider);
  return LocalAdminRepository(
    userRepository: userRepo,
    circleRepository: circleRepo,
  );
});

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getStats();
});

final pendingVerificationsProvider = FutureProvider<List<VerificationRequest>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getPendingVerifications();
});

final reportsQueueProvider = FutureProvider<List<ReportModel>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getReportQueue();
});

final allowedDomainsProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getAllowedDomains();
});
