import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/college_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/auth_provider.dart';
import '../../../state/discovery_provider.dart';
import '../../components/custom_button.dart';
import '../../components/custom_text_field.dart';
import '../../components/interest_chip.dart';
import '../../components/profile_avatar.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _availabilityController;
  late TextEditingController _promptAnswerController;

  late String _department;
  late String _year;
  late String _selectedPrompt;
  late Set<String> _interests;
  late String _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _availabilityController = TextEditingController(text: user?.socialAvailability ?? '');
    
    _department = user?.department ?? CollegeData.departments.first;
    _year = user?.academicYear ?? CollegeData.academicYears[2];
    _selectedPrompt = user?.prompts.isNotEmpty == true
        ? user!.prompts.keys.first
        : CollegeData.profilePrompts.first;
    _promptAnswerController = TextEditingController(
      text: user?.prompts[_selectedPrompt] ?? '',
    );
    _interests = Set.from(user?.interests ?? []);
    _profileImage = user?.profileImage ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _availabilityController.dispose();
    _promptAnswerController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    final currentUser = ref.read(authProvider).value;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    final updatedPrompts = Map<String, String>.from(currentUser.prompts);
    if (_promptAnswerController.text.trim().isNotEmpty) {
      updatedPrompts[_selectedPrompt] = _promptAnswerController.text.trim();
    }

    final updated = currentUser.copyWith(
      name: _nameController.text.trim(),
      department: _department,
      academicYear: _year,
      bio: _bioController.text.trim(),
      socialAvailability: _availabilityController.text.trim(),
      interests: _interests.toList(),
      prompts: updatedPrompts,
      profileImage: _profileImage,
    );

    await ref.read(authProvider.notifier).updateProfile(updated);
    ref.read(discoveryProvider.notifier).refresh();

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Campus Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.primaryAccent),
            onPressed: _handleSave,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      ProfileAvatar(
                        imageUrl: _profileImage,
                        name: _nameController.text,
                        radius: 46,
                        showVerifiedBadge: true,
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        icon: const Icon(Icons.photo_camera_outlined, size: 18),
                        label: const Text('Change Photo'),
                        onPressed: () {
                          // Cycle avatar sample
                          final samples = [
                            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
                            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
                            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
                            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
                          ];
                          setState(() {
                            _profileImage = samples[(samples.indexOf(_profileImage) + 1) % samples.length];
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),
                // Department Dropdown
                Text(
                  'Department',
                  style: AppTypography.labelLarge(
                    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _department,
                  isExpanded: true,
                  items: CollegeData.departments.map((dept) {
                    return DropdownMenuItem(value: dept, child: Text(dept));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _department = val);
                  },
                ),
                const SizedBox(height: 16),
                // Academic Year Dropdown
                Text(
                  'Academic Year',
                  style: AppTypography.labelLarge(
                    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _year,
                  items: CollegeData.academicYears.map((yr) {
                    return DropdownMenuItem(value: yr, child: Text(yr));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _year = val);
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _bioController,
                  label: 'Short Bio',
                  hint: 'Tell others what you enjoy studying or discussing...',
                  maxLines: 3,
                  maxLength: 250,
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
                  'Interests (Tap to toggle)',
                  style: AppTypography.titleMedium(
                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: CollegeData.allInterests.map((interest) {
                    final isSel = _interests.contains(interest);
                    return InterestChip(
                      label: interest,
                      isSelected: isSel,
                      onTap: () {
                        setState(() {
                          if (isSel) {
                            _interests.remove(interest);
                          } else if (_interests.length < 10) {
                            _interests.add(interest);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Prompt
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
                    if (val != null) {
                      setState(() {
                        _selectedPrompt = val;
                        final user = ref.read(authProvider).value;
                        _promptAnswerController.text = user?.prompts[val] ?? '';
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _promptAnswerController,
                  label: 'Your Answer',
                  maxLines: 2,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Save Changes',
                  width: double.infinity,
                  isLoading: _isLoading,
                  onPressed: _handleSave,
                  variant: ButtonVariant.primary,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
