import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/auth_provider.dart';
import '../../../state/connection_provider.dart';
import '../../../state/circle_provider.dart';
import '../../components/custom_button.dart';
import '../../components/interest_chip.dart';
import '../../components/profile_avatar.dart';
import '../../components/prompt_card.dart';
import '../../components/status_badge.dart';

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(authProvider).value;
    final connectionsCount = ref.watch(myConnectionsProvider).value?.length ?? 0;
    final joinedCirclesCount = ref.watch(joinedCirclesProvider).value?.length ?? 0;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

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
            const Text('My Campus Profile'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/account-settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Avatar & Name Header
              Center(
                child: Column(
                  children: [
                    ProfileAvatar(
                      imageUrl: currentUser.profileImage,
                      name: currentUser.name,
                      radius: 48,
                      showVerifiedBadge: currentUser.verified,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      currentUser.name,
                      style: AppTypography.headlineLarge(
                        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currentUser.department} • ${currentUser.academicYear}',
                      style: AppTypography.titleMedium(AppColors.secondaryAccent),
                    ),
                    const SizedBox(height: 10),
                    StatusBadge(
                      text: currentUser.verified ? 'Verified TKMCE Student' : 'Verification In-Progress',
                      icon: currentUser.verified ? Icons.verified : Icons.hourglass_top,
                      color: currentUser.verified ? AppColors.highlight : AppColors.warning,
                      isGlowing: currentUser.verified,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Connections',
                      value: '$connectionsCount',
                      icon: Icons.people_outline,
                      onTap: () => context.push('/connections'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'My Circles',
                      value: '$joinedCirclesCount',
                      icon: Icons.groups_outlined,
                      onTap: () => context.push('/circles'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Interests',
                      value: '${currentUser.interests.length}',
                      icon: Icons.bolt_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Edit Profile & Preview Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Edit Profile',
                      icon: Icons.edit_outlined,
                      variant: ButtonVariant.primary,
                      onPressed: () => context.push('/edit-profile'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Privacy Controls',
                      icon: Icons.lock_outline,
                      variant: ButtonVariant.secondary,
                      onPressed: () => context.push('/privacy-settings'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Social Availability
              if (currentUser.socialAvailability.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.highlight.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.highlight.withOpacity(0.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: AppColors.highlight, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          currentUser.socialAvailability,
                          style: AppTypography.bodyMedium(
                            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              // Bio
              Text(
                'About Me',
                style: AppTypography.titleMedium(
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                currentUser.bio.isEmpty
                    ? 'No bio added yet. Tell campus what you are interested in!'
                    : currentUser.bio,
                style: AppTypography.bodyLarge(
                  isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 20),
              // Interests
              Text(
                'Interests & Hobbies',
                style: AppTypography.titleMedium(
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: currentUser.interests.map((i) => InterestChip(label: i)).toList(),
              ),
              const SizedBox(height: 20),
              // Profile Prompts
              if (currentUser.prompts.isNotEmpty) ...[
                Text(
                  'Profile Prompts',
                  style: AppTypography.titleMedium(
                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...currentUser.prompts.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PromptCard(question: e.key, answer: e.value),
                  );
                }),
                const SizedBox(height: 16),
              ],
              // Admin portal button (if admin)
              if (currentUser.isAdmin) ...[
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.highlightWarm.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.highlightWarm.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.admin_panel_settings_rounded, color: AppColors.highlightWarm, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Administration Portal',
                              style: AppTypography.titleMedium(AppColors.highlightWarm),
                            ),
                            Text(
                              'Manage student verification & moderation queue',
                              style: AppTypography.labelSmall(AppColors.darkTextSecondary),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.highlightWarm,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => context.push('/admin'),
                        child: const Text('Open'),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget card = Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryAccent),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.headlineMedium(
              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelSmall(
              isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(borderRadius: BorderRadius.circular(16), onTap: onTap, child: card);
    }
    return card;
  }
}
