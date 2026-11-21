import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/college_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/auth_provider.dart';
import '../../components/custom_button.dart';
import '../../components/custom_text_field.dart';
import '../../components/interest_chip.dart';
import '../../components/profile_avatar.dart';

class ProfileCreationScreen extends ConsumerStatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  ConsumerState<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends ConsumerState<ProfileCreationScreen> {
  final _bioController = TextEditingController();
  final _availabilityController = TextEditingController(text: 'Available around Nescafe corner & Library');
  final _promptAnswerController = TextEditingController();

  String _selectedPrompt = CollegeData.profilePrompts.first;
  final Set<String> _selectedInterests = {
    'Flutter & Mobile',
    'Malayalam Cinema',
    'UI/UX Design',
  };
  String _selectedAvatarUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80';
  bool _isSaving = false;

  final List<String> _sampleAvatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
  ];

  @override
  void dispose() {
    _bioController.dispose();
    _availabilityController.dispose();
    _promptAnswerController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    final currentUser = ref.read(authProvider).value;
    if (currentUser != null) {
      final updatedPrompts = Map<String, String>.from(currentUser.prompts);
      if (_promptAnswerController.text.trim().isNotEmpty) {
        updatedPrompts[_selectedPrompt] = _promptAnswerController.text.trim();
      }

      final updatedUser = currentUser.copyWith(
        bio: _bioController.text.trim().isEmpty
            ? 'TKMCE student eager to meet new friends and collaborate.'
            : _bioController.text.trim(),
        profileImage: _selectedAvatarUrl,
        interests: _selectedInterests.toList(),
        socialAvailability: _availabilityController.text.trim(),
        prompts: updatedPrompts,
        discoverable: true,
      );

      await ref.read(authProvider.notifier).updateProfile(updatedUser);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      context.go('/discover');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: const Text('Skip / Done'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Make it Easy to Discover You',
                style: AppTypography.displayMedium(
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Showcase your interests and hangout availability to other TKMCE students.',
                style: AppTypography.bodyMedium(
                  isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 24),
              // Avatar Chooser
              Center(
                child: Column(
                  children: [
                    ProfileAvatar(
                      imageUrl: _selectedAvatarUrl,
                      name: currentUser?.name ?? 'Student',
                      radius: 46,
                      showVerifiedBadge: true,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Choose Campus Avatar',
                      style: AppTypography.labelLarge(
                        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _sampleAvatars.map((url) {
                        final isSel = _selectedAvatarUrl == url;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedAvatarUrl = url),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? AppColors.primaryAccent : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(url),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              CustomTextField(
                controller: _bioController,
                label: 'Short Bio',
                hint: 'e.g. 3rd year CSE. Fan of indie rock, hackathons, and evening tea breaks.',
                maxLines: 3,
                maxLength: 200,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _availabilityController,
                label: 'Social Availability Status',
                hint: 'e.g. Free after 4 PM at Nescafe corner',
                prefixIcon: Icons.access_time_rounded,
              ),
              const SizedBox(height: 24),
              Text(
                'Pick Your Interests (Select up to 10)',
                style: AppTypography.titleMedium(
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: CollegeData.allInterests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return InterestChip(
                    label: interest,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedInterests.remove(interest);
                        } else if (_selectedInterests.length < 10) {
                          _selectedInterests.add(interest);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              // Profile Prompt
              Text(
                'Campus Profile Prompt',
                style: AppTypography.titleMedium(
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPrompt,
                isExpanded: true,
                items: CollegeData.profilePrompts.map((p) {
                  return DropdownMenuItem(value: p, child: Text(p));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPrompt = val);
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _promptAnswerController,
                label: 'Your Answer',
                hint: 'Type your answer here...',
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Launch Discover',
                width: double.infinity,
                isLoading: _isSaving,
                onPressed: _handleSave,
                variant: ButtonVariant.primary,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
