import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/college_data.dart';
import '../../../core/constants/tk_avatars.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/avatar_processor.dart';
import '../../../state/auth_provider.dart';
import '../../components/custom_button.dart';
import '../../components/custom_text_field.dart';
import '../../components/interest_chip.dart';
import '../../components/preset_avatar_picker_sheet.dart';
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
  String _selectedAvatarUrl = 'preset:tk_avatar_01';
  String? _avatarType = 'preset';
  String? _avatarId = 'tk_avatar_01';
  bool _isSaving = false;
  bool _isProcessingAvatar = false;

  @override
  void dispose() {
    _bioController.dispose();
    _availabilityController.dispose();
    _promptAnswerController.dispose();
    super.dispose();
  }

  Future<void> _handlePickPhoto(ImageSource source) async {
    final currentUser = ref.read(authProvider).value;
    setState(() => _isProcessingAvatar = true);
    try {
      final res = await AvatarProcessor.pickAndProcessImage(source);
      if (res != null) {
        String newUrl;
        if (currentUser != null) {
          try {
            newUrl = await AvatarProcessor.uploadAvatar(
              userId: currentUser.uid,
              imageBytes: res.bytes,
            );
          } catch (e) {
            newUrl = _selectedAvatarUrl;
          }
        } else {
          newUrl = _selectedAvatarUrl;
        }

        setState(() {
          _selectedAvatarUrl = newUrl;
          _avatarType = 'upload';
          _avatarId = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not process photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingAvatar = false);
    }
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
        avatarType: _avatarType,
        avatarId: _avatarId,
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
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ProfileAvatar(
                          imageUrl: _selectedAvatarUrl,
                          name: currentUser?.name ?? 'Student',
                          avatarType: _avatarType,
                          avatarId: _avatarId,
                          radius: 46,
                          showVerifiedBadge: true,
                        ),
                        if (_isProcessingAvatar)
                          Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.highlight),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Choose Campus Avatar',
                      style: AppTypography.labelLarge(
                        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Quick brand avatar row (first 4 presets) + More + Upload
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...TkAvatars.all.take(4).map((avatar) {
                          final isSel = _avatarId == avatar.id || _selectedAvatarUrl == 'preset:${avatar.id}';
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAvatarUrl = 'preset:${avatar.id}';
                                _avatarType = 'preset';
                                _avatarId = avatar.id;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSel ? AppColors.highlight : Colors.white24,
                                  width: isSel ? 2.5 : 1,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.darkCard,
                                backgroundImage: AssetImage(avatar.assetPath),
                              ),
                            ),
                          );
                        }),
                        // More presets button
                        GestureDetector(
                          onTap: () async {
                            final chosen = await PresetAvatarPickerSheet.show(
                              context,
                              currentAvatarId: _avatarId,
                            );
                            if (chosen != null) {
                              setState(() {
                                _selectedAvatarUrl = 'preset:${chosen.id}';
                                _avatarType = 'preset';
                                _avatarId = chosen.id;
                              });
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.darkCard,
                              border: Border.all(color: AppColors.primaryAccent.withOpacity(0.5)),
                            ),
                            child: const Icon(
                              Icons.grid_view_rounded,
                              size: 18,
                              color: AppColors.primaryAccent,
                            ),
                          ),
                        ),
                        // Upload custom photo button
                        GestureDetector(
                          onTap: () => _handlePickPhoto(ImageSource.gallery),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.darkCard,
                              border: Border.all(color: AppColors.highlight.withOpacity(0.5)),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 18,
                              color: AppColors.highlight,
                            ),
                          ),
                        ),
                      ],
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
