import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/mock/seed_data.dart';
import '../../../state/auth_provider.dart';
import '../../components/tkmingle_components.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNavy : AppColors.lightBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient glow
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.tkmPurple.withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  // Architectural Brand Emblem with glow
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        color: AppColors.secondaryBackground,
                        border: Border.all(color: AppColors.border, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.tkmPurple.withOpacity(0.35),
                            blurRadius: 28,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          AppAssets.appIcon,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Brand Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'TKM',
                        style: AppTypography.displayMedium(
                          isDark ? Colors.white : AppColors.deepNavy,
                        ).copyWith(letterSpacing: -0.5),
                      ),
                      Text(
                        'ingle',
                        style: AppTypography.displayMedium(
                          AppColors.tkmPurple,
                        ).copyWith(letterSpacing: -0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppConstants.appTagline,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium(
                      isDark ? AppColors.mutedText : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Value Propositions matching Section 6
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _FeatureTile(
                          icon: Icons.alt_route_rounded,
                          title: 'Beyond Your Department',
                          subtitle: 'Break the branch silo. Connect with ME, EC, CS, Civil, and Arch students.',
                        ),
                        const SizedBox(height: 12),
                        _FeatureTile(
                          icon: Icons.bubble_chart_rounded,
                          title: 'Shared Interests & Passions',
                          subtitle: 'Discover campus friends who love coding, robotics, acoustic jams, or anime.',
                        ),
                        const SizedBox(height: 12),
                        _FeatureTile(
                          icon: Icons.shield_outlined,
                          title: 'Private & Verified Community',
                          subtitle: 'Strict student verification for TKMCE students. Zero harassment or anonymous toxicity.',
                        ),
                      ],
                    ),
                  ),

                  // Demo Switcher Pill
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.secondaryBackground : AppColors.lightElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppColors.border : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flash_on_rounded, size: 16, color: AppColors.accentTeal),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Demo Mode: Sample student profiles ready',
                            style: AppTypography.metadata(
                              isDark ? AppColors.mutedText : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showQuickDemoModal(context, ref),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Try Demo', style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.w600, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                  // Primary Button ("Get Started ->" as shown on brand board)
                  TKMinglePrimaryButton(
                    text: 'Get Started  →',
                    onPressed: () => context.push('/register'),
                  ),
                  const SizedBox(height: 12),

                  // Secondary Button ("Login" as shown on brand board)
                  TKMingleSecondaryButton(
                    text: 'Login',
                    onPressed: () => context.push('/login'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickDemoModal(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardBackground : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a Demo Account',
                  style: AppTypography.headlineMedium(
                    isDark ? AppColors.primaryText : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Switch immediately to experience discovery or administrative moderation:',
                  style: AppTypography.bodyMedium(
                    isDark ? AppColors.mutedText : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: SeedData.sampleUsers.map((user) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.profileImage.isNotEmpty ? NetworkImage(user.profileImage) : null,
                          backgroundColor: AppColors.tkmPurple,
                          child: user.profileImage.isEmpty ? Text(user.name[0]) : null,
                        ),
                        title: Text(user.name, style: AppTypography.titleMedium(isDark ? AppColors.primaryText : AppColors.lightTextPrimary)),
                        subtitle: Text('${user.department} • ${user.role.toUpperCase()}', style: AppTypography.metadata(AppColors.mutedText)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.mutedText),
                        onTap: () async {
                          Navigator.pop(ctx);
                          await ref.read(authProvider.notifier).switchUser(user);
                          if (context.mounted) {
                            if (user.isAdmin) {
                              context.go('/admin');
                            } else {
                              context.go('/discover');
                            }
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackground : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.tkmPurple.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.tkmPurple, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium(
                    isDark ? AppColors.primaryText : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodyMedium(
                    isDark ? AppColors.mutedText : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
