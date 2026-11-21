import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/admin_provider.dart';
import '../../components/empty_state_view.dart';
import '../../components/status_badge.dart';

class AdminVerificationScreen extends ConsumerWidget {
  const AdminVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final verificationsAsync = ref.watch(pendingVerificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Verification Queue'),
      ),
      body: SafeArea(
        child: verificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (requests) {
            if (requests.isEmpty) {
              return const EmptyStateView(
                icon: Icons.check_circle_outline_rounded,
                title: 'Queue is Clear!',
                message: 'All submitted student ID verification requests have been reviewed.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final req = requests[index];
                final student = req.user;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              student.name,
                              style: AppTypography.headlineMedium(
                                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const StatusBadge(
                              text: 'Pending Review',
                              color: AppColors.warning,
                              icon: Icons.hourglass_empty,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${student.department} • ${student.academicYear}',
                          style: AppTypography.titleMedium(AppColors.secondaryAccent),
                        ),
                        Text(
                          'Email: ${student.email}',
                          style: AppTypography.bodyMedium(AppColors.darkTextSecondary),
                        ),
                        const SizedBox(height: 14),
                        // ID Document Preview Card
                        Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.darkElevated,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: req.documentUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    req.documentUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Center(child: Icon(Icons.badge, size: 48)),
                                  ),
                                )
                              : const Center(child: Icon(Icons.badge, size: 48)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Document Submitted: ${req.documentType}',
                          style: AppTypography.labelSmall(AppColors.darkTextMuted),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                                onPressed: () async {
                                  await ref.read(adminRepositoryProvider).reviewVerification(
                                        req.requestId,
                                        false,
                                        student.uid,
                                      );
                                  ref.invalidate(pendingVerificationsProvider);
                                  ref.invalidate(adminStatsProvider);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Verification rejected.')),
                                    );
                                  }
                                },
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.highlight),
                                onPressed: () async {
                                  await ref.read(adminRepositoryProvider).reviewVerification(
                                        req.requestId,
                                        true,
                                        student.uid,
                                      );
                                  ref.invalidate(pendingVerificationsProvider);
                                  ref.invalidate(adminStatsProvider);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${student.name} approved as Verified Student!'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Approve & Verify', style: TextStyle(color: Colors.black)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
