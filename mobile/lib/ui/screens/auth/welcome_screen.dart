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
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.tkmPurple.withOpacity(0.35),
                            blurRadius: 28,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          AppAssets.appIcon,
                          fit: BoxFit.contain,
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

                  const SizedBox(height: 16),

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
