import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/college_data.dart';
import '../../../core/constants/tk_avatars.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/avatar_processor.dart';
import '../../../state/auth_provider.dart';
import '../../../state/discovery_provider.dart';
import '../../components/custom_button.dart';
import '../../components/custom_text_field.dart';
import '../../components/interest_chip.dart';
import '../../components/preset_avatar_picker_sheet.dart';
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
  String? _avatarType;
  String? _avatarId;
  bool _isLoading = false;
  bool _isProcessingAvatar = false;

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
    _avatarType = user?.avatarType;
    _avatarId = user?.avatarId;
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
      avatarType: _avatarType,
      avatarId: _avatarId,
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

  Future<void> _showAvatarActionSheet() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.primaryAccent, width: 1.5),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Change Profile Picture',
                style: AppTypography.titleMedium(Colors.white).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.highlight),
                title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Use camera with auto square crop & optimization', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _processAndUploadPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primaryAccent),
                title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Pick photo from your device (compressed <= 100 KB)', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _processAndUploadPhoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.face_outlined, color: AppColors.lavender),
                title: const Text('Choose Brand Avatar', style: TextStyle(color: Colors.white)),
                subtitle: const Text('24 built-in campus illustrations', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final selected = await PresetAvatarPickerSheet.show(
                    context,
                    currentAvatarId: _avatarId ?? _profileImage,
                  );
                  if (selected != null) {
                    _selectPreset(selected);
                  }
                },
              ),
              if (_profileImage.isNotEmpty && !_profileImage.startsWith('initial'))
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: const Text('Remove Photo', style: TextStyle(color: AppColors.error)),
                  subtitle: const Text('Reset to brand initials fallback', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _removeAvatar();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processAndUploadPhoto(ImageSource source) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    setState(() => _isProcessingAvatar = true);
    try {
      final result = await AvatarProcessor.pickAndProcessImage(source);
      if (result == null) {
        setState(() => _isProcessingAvatar = false);
        return;
      }

      String newUrl;
      try {
        newUrl = await AvatarProcessor.uploadAvatar(
          userId: user.uid,
          imageBytes: result.bytes,
        );
      } catch (uploadErr) {
        debugPrint('Remote storage upload notice: $uploadErr');
        // Fallback to local memory representation if backend storage is unavailable
        newUrl = _profileImage;
      }

      setState(() {
        _profileImage = newUrl;
        _avatarType = 'upload';
        _avatarId = null;
      });

      final updated = user.copyWith(
        profileImage: newUrl,
        avatarType: 'upload',
        avatarId: null,
      );
      await ref.read(authProvider.notifier).updateProfile(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile photo updated (${(result.byteSize / 1024).toStringAsFixed(1)} KB)'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingAvatar = false);
    }
  }

  Future<void> _selectPreset(TkAvatar preset) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    setState(() {
      _profileImage = 'preset:${preset.id}';
      _avatarType = 'preset';
      _avatarId = preset.id;
    });

    try {
      await AvatarProcessor.selectPresetAvatar(
        userId: user.uid,
        avatarId: preset.id,
      );
    } catch (e) {
      debugPrint('Preset avatar remote update note: $e');
    }

    final updated = user.copyWith(
      profileImage: 'preset:${preset.id}',
      avatarType: 'preset',
      avatarId: preset.id,
    );
    await ref.read(authProvider.notifier).updateProfile(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected avatar: ${preset.name}'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _removeAvatar() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    setState(() {
      _profileImage = '';
      _avatarType = 'initial';
      _avatarId = null;
    });

    try {
      await AvatarProcessor.removeAvatar(userId: user.uid);
    } catch (e) {
      debugPrint('Avatar removal notice: $e');
    }

    final updated = user.copyWith(
      profileImage: '',
      avatarType: 'initial',
      avatarId: null,
    );
    await ref.read(authProvider.notifier).updateProfile(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo removed. Using initials fallback.'),
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
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ProfileAvatar(
                            imageUrl: _profileImage,
                            name: _nameController.text,
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
                      const SizedBox(height: 10),
                      TextButton.icon(
                        icon: const Icon(Icons.photo_camera_outlined, size: 18),
                        label: const Text('Change Avatar / Photo'),
                        onPressed: _isProcessingAvatar ? null : _showAvatarActionSheet,
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
