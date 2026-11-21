import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/admin_provider.dart';
import '../../../state/auth_provider.dart';
import '../../components/custom_button.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(authProvider).value;
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                color: AppColors.secondaryBackground,
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/images/app_icon.png', fit: BoxFit.cover),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TKMCE Admin Console',
                  style: AppTypography.headlineLarge(
                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  'Student Verification & Campus Council Moderation',
                  style: AppTypography.labelSmall(AppColors.error),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Switch to Student View',
            icon: const Icon(Icons.swap_horiz_rounded),
            onPressed: () => context.go('/discover'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(adminStatsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Admin Header Badge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryAccent.withOpacity(0.2),
                      AppColors.highlightWarm.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.highlightWarm.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings, size: 36, color: AppColors.highlightWarm),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser?.name ?? 'Admin Officer',
                            style: AppTypography.titleMedium(
                              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            'Institutional Dean / Student Council Moderator',
                            style: AppTypography.labelSmall(AppColors.secondaryAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Campus Community Metrics',
                style: AppTypography.titleMedium(AppColors.secondaryAccent),
              ),
              const SizedBox(height: 12),
              // Stats Grid
              statsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error: $err'),
                data: (stats) {
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _MetricTile(
                        label: 'Total Registered',
                        value: '${stats.totalStudents}',
                        icon: Icons.school_outlined,
                        color: AppColors.primaryAccent,
                      ),
                      _MetricTile(
                        label: 'Verified Students',
                        value: '${stats.verifiedStudents}',
                        icon: Icons.verified_outlined,
                        color: AppColors.highlight,
                      ),
                      _MetricTile(
                        label: 'Pending ID Review',
                        value: '${stats.pendingVerifications}',
                        icon: Icons.badge_outlined,
                        color: AppColors.warning,
                        onTap: () => context.push('/admin/verifications'),
                      ),
                      _MetricTile(
                        label: 'Active Circles',
                        value: '${stats.activeCircles}',
                        icon: Icons.groups_outlined,
                        color: AppColors.secondaryAccent,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Management Queues',
                style: AppTypography.titleMedium(AppColors.secondaryAccent),
              ),
              const SizedBox(height: 12),
              // Card for Verification Queue
              _AdminActionCard(
                title: 'Student ID Verification Queue',
                subtitle: 'Review manual student ID card and admission fee uploads for non-institutional email accounts.',
                icon: Icons.assignment_ind_outlined,
                badgeCount: statsAsync.value?.pendingVerifications ?? 0,
                badgeColor: AppColors.warning,
                onTap: () => context.push('/admin/verifications'),
              ),
              const SizedBox(height: 12),
              // Card for Moderation Queue
              _AdminActionCard(
                title: 'Safety Reports & Moderation Queue',
                subtitle: 'Investigate reported student profiles, harassment flags, spam messages, and account suspensions.',
                icon: Icons.shield_outlined,
                badgeCount: statsAsync.value?.pendingReports ?? 0,
                badgeColor: AppColors.error,
                onTap: () => context.push('/admin/moderation'),
              ),
              const SizedBox(height: 12),
              // Card for Domain Configuration
              _AdminActionCard(
                title: 'Allowed College Email Domains',
                subtitle: 'Configure approved institutional domains (default: tkmce.ac.in).',
                icon: Icons.domain_verification_outlined,
                onTap: () => _showDomainSettingsModal(context, ref),
              ),
              const SizedBox(height: 28),
              CustomButton(
                text: 'Return to Student Discovery',
                icon: Icons.arrow_back_rounded,
                width: double.infinity,
                variant: ButtonVariant.outline,
                onPressed: () => context.go('/discover'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showDomainSettingsModal(BuildContext context, WidgetRef ref) {
    final domainCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Allowed College Email Domains', style: AppTypography.headlineMedium(Colors.white)),
              const SizedBox(height: 6),
              const Text('Students registering with these domains bypass manual ID review:'),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: const Text('tkmce.ac.in (Default)'),
                    backgroundColor: AppColors.primaryAccent.withOpacity(0.2),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: domainCtrl,
                decoration: const InputDecoration(
                  hintText: 'Add new domain (e.g. tkmce.edu.in)',
                  prefixIcon: Icon(Icons.add),
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Save Domain Configuration',
                width: double.infinity,
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Domain configuration saved!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 22),
              if (onTap != null)
                const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.darkTextMuted),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.headlineLarge(
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                label,
                style: AppTypography.labelSmall(
                  isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(borderRadius: BorderRadius.circular(16), onTap: onTap, child: content);
    }
    return content;
  }
}

class _AdminActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int badgeCount;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _AdminActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.badgeCount = 0,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primaryAccent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTypography.titleMedium(
                              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        if (badgeCount > 0) ...[
                          const SizedBox(width: 6),
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: badgeColor ?? AppColors.primaryAccent,
                            child: Text(
                              '$badgeCount',
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.bodyMedium(
                        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.darkTextMuted),
            ],
          ),
        ),
      ),
    );
  }
}
