import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/admin_provider.dart';
import '../../components/empty_state_view.dart';
import '../../components/status_badge.dart';

class AdminModerationScreen extends ConsumerWidget {
  const AdminModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reportsAsync = ref.watch(reportsQueueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Moderation & Reports'),
      ),
      body: SafeArea(
        child: reportsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (reports) {
            final pending = reports.where((r) => r.status == 'pending').toList();

            if (pending.isEmpty) {
              return const EmptyStateView(
                icon: Icons.verified_user_outlined,
                title: 'No Pending Reports',
                message: 'Campus community standards are clean. No student safety flags require investigation.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: pending.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final report = pending[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: AppColors.error.withOpacity(0.4),
                      width: 1.2,
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
                              'Flagged: ${report.reportedUserName}',
                              style: AppTypography.headlineMedium(
                                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const StatusBadge(
                              text: 'Violation Flag',
                              color: AppColors.error,
                              icon: Icons.warning_amber_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Reported by: ${report.reporterName}',
                          style: AppTypography.labelSmall(AppColors.secondaryAccent),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reason: ${report.reason}',
                                style: AppTypography.titleMedium(AppColors.highlightWarm),
                              ),
                              if (report.details.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Details: "${report.details}"',
                                  style: AppTypography.bodyMedium(
                                    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await ref.read(adminRepositoryProvider).resolveReport(
                                        report.id,
                                        'dismiss',
                                        report.reportedUserId,
                                      );
                                  ref.invalidate(reportsQueueProvider);
                                  ref.invalidate(adminStatsProvider);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Report dismissed.')),
                                    );
                                  }
                                },
                                child: const Text('Dismiss'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                onPressed: () async {
                                  await ref.read(adminRepositoryProvider).resolveReport(
                                        report.id,
                                        'suspend',
                                        report.reportedUserId,
                                      );
                                  ref.invalidate(reportsQueueProvider);
                                  ref.invalidate(adminStatsProvider);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${report.reportedUserName} has been suspended from campus discovery.'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Suspend Account', style: TextStyle(color: Colors.white)),
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
