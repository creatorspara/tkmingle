import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/college_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/user_model.dart';
import '../../../state/auth_provider.dart';
import '../../../state/connection_provider.dart';
import '../../../state/user_provider.dart';
import '../../../state/chat_provider.dart';
import '../../components/custom_button.dart';
import '../../components/interest_chip.dart';
import '../../components/prompt_card.dart';
import '../../components/status_badge.dart';
import '../safety/report_block_sheet.dart';

class FullStudentProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const FullStudentProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<FullStudentProfileScreen> createState() => _FullStudentProfileScreenState();
}

class _FullStudentProfileScreenState extends ConsumerState<FullStudentProfileScreen> {
  bool _isActionLoading = false;

  void _openSafetyMenu(String userName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReportBlockSheet(
        targetUserId: widget.userId,
        targetUserName: userName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(authProvider).value;
    final userAsync = ref.watch(userProfileProvider(widget.userId));
    final connStatusAsync = ref.watch(connectionStatusProvider(widget.userId));

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $err')),
      ),
      data: (student) {
        if (student == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Student profile not found')),
          );
        }

        final connStatus = connStatusAsync.value ?? 'none';
        final commonInterests = student.interests
            .where((i) => currentUser?.interests.contains(i) ?? false)
            .toList();

        return Scaffold(
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Silver Hero App Bar with Full Photo
              SliverAppBar(
                expandedHeight: 340,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      student.profileImage.isNotEmpty
                          ? Image.network(
                              student.profileImage,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: AppColors.darkElevated,
                              child: const Icon(Icons.person, size: 80, color: AppColors.darkTextMuted),
                            ),
                      // Scrim
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.darkBackground.withOpacity(0.9),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded),
                    onPressed: () => _openSafetyMenu(student.name),
                  ),
                ],
              ),
              // Profile Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name & Badges
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              student.name,
                              style: AppTypography.displayMedium(
                                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          if (student.verified)
                            const StatusBadge(
                              text: 'Verified Student',
                              icon: Icons.verified,
                              color: AppColors.highlight,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${student.department} • ${student.academicYear}',
                        style: AppTypography.titleMedium(AppColors.secondaryAccent),
                      ),
                      const SizedBox(height: 16),
                      // Social Availability Card
                      if (student.socialAvailability.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.highlight.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.highlight.withOpacity(0.35)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_filled_rounded, color: AppColors.highlight, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Campus Social Availability',
                                      style: AppTypography.labelSmall(AppColors.highlight).copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      student.socialAvailability,
                                      style: AppTypography.bodyMedium(
                                        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                  ],
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
                        style: AppTypography.headlineMedium(
                          isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        student.bio,
                        style: AppTypography.bodyLarge(
                          isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Interests
                      Row(
                        children: [
                          Text(
                            'Interests & Passions',
                            style: AppTypography.headlineMedium(
                              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          if (commonInterests.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            StatusBadge(
                              text: '${commonInterests.length} Mutual',
                              icon: Icons.bolt,
                              color: AppColors.highlight,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        children: student.interests.map((i) {
                          return InterestChip(
                            label: i,
                            isMutual: commonInterests.contains(i),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      // Skills & Hobbies
                      if (student.skills.isNotEmpty) ...[
                        Text(
                          'Skills & Expertise',
                          style: AppTypography.headlineMedium(
                            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: student.skills.map((s) {
                            return Chip(
                              label: Text(s),
                              backgroundColor: isDark ? AppColors.darkElevated : AppColors.lightElevated,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                      // Profile Prompts
                      if (student.prompts.isNotEmpty) ...[
                        Text(
                          'Campus Prompts',
                          style: AppTypography.headlineMedium(
                            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...student.prompts.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: PromptCard(
                              question: entry.key,
                              answer: entry.value,
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                      // Icebreaker starters
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.lightbulb_outline, size: 20, color: AppColors.highlight),
                                const SizedBox(width: 8),
                                Text(
                                  'Campus Icebreakers',
                                  style: AppTypography.titleMedium(
                                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...CollegeData.icebreakers.take(3).map((ib) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(color: AppColors.primaryAccent)),
                                    Expanded(
                                      child: Text(
                                        ib,
                                        style: AppTypography.bodyMedium(
                                          isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 90), // Spacing for bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: SafeArea(
              child: _buildBottomAction(context, connStatus, student, currentUser),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomAction(
    BuildContext context,
    String connStatus,
    UserModel student,
    UserModel? currentUser,
  ) {
    if (connStatus == 'connected') {
      return CustomButton(
        text: 'Message ${student.name.split(' ').first}',
        icon: Icons.chat_bubble_outline_rounded,
        width: double.infinity,
        onPressed: () async {
          if (currentUser == null) return;
          final conv = await ref
              .read(messageRepositoryProvider)
              .getOrCreateConversation(currentUser.uid, student.uid);
          if (context.mounted) {
            context.push('/chat/${conv.conversationId}');
          }
        },
        variant: ButtonVariant.primary,
      );
    }

    if (connStatus == 'pending_sent') {
      return CustomButton(
        text: 'Connection Request Pending',
        icon: Icons.hourglass_top_rounded,
        width: double.infinity,
        onPressed: null,
        variant: ButtonVariant.secondary,
      );
    }

    if (connStatus == 'pending_received') {
      return CustomButton(
        text: 'Accept Connection Request',
        icon: Icons.check_circle_outline,
        width: double.infinity,
        onPressed: () async {
          setState(() => _isActionLoading = true);
          final received = await ref.read(connectionRepositoryProvider).getReceivedRequests(currentUser?.uid ?? '');
          final match = received.firstWhere((r) => r.senderId == student.uid);
          await ref.read(connectionRepositoryProvider).acceptRequest(match.id);
          ref.invalidate(connectionStatusProvider(student.uid));
          ref.invalidate(myConnectionsProvider);
          if (mounted) setState(() => _isActionLoading = false);
        },
        variant: ButtonVariant.primary,
      );
    }

    // None - Send Connection Request
    return CustomButton(
      text: 'Send Connection Request',
      icon: Icons.person_add_rounded,
      width: double.infinity,
      isLoading: _isActionLoading,
      onPressed: () async {
        HapticFeedback.mediumImpact();
        setState(() => _isActionLoading = true);
        if (currentUser != null) {
          await ref.read(connectionRepositoryProvider).sendRequest(currentUser.uid, student.uid);
          ref.invalidate(connectionStatusProvider(student.uid));
          ref.invalidate(sentRequestsProvider);
        }
        if (mounted) {
          setState(() => _isActionLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connection request sent to ${student.name}!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      variant: ButtonVariant.primary,
    );
  }
}
