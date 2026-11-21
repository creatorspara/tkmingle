import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/college_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/auth_provider.dart';
import '../../../state/circle_provider.dart';
import '../../components/custom_button.dart';
import '../../components/custom_text_field.dart';

class CreateCircleScreen extends ConsumerStatefulWidget {
  const CreateCircleScreen({super.key});

  @override
  ConsumerState<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends ConsumerState<CreateCircleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedCategory = CollegeData.interestCategories.first;
  String _selectedIcon = '👥';
  bool _isLoading = false;

  final List<String> _icons = ['💻', '⚽', '🎸', '🎨', '🎬', '🚀', '🎮', '📚', '🤖', '🏸', '📷', '👥'];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final circle = await ref.read(circleRepositoryProvider).createCircle(
            name: _nameController.text.trim(),
            description: _descController.text.trim(),
            category: _selectedCategory,
            icon: _selectedIcon,
            createdBy: user.uid,
          );

      ref.invalidate(circlesListProvider);
      ref.invalidate(joinedCirclesProvider);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Circle "${circle.name}" created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/circle/${circle.circleId}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start a Campus Circle'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Build Your Tribe at TKMCE',
                  style: AppTypography.displayMedium(
                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create an open community for hobbies, department discussions, or campus activities.',
                  style: AppTypography.bodyMedium(
                    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                // Icon Chooser
                Text(
                  'Circle Icon',
                  style: AppTypography.titleMedium(
                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _icons.map((emoji) {
                    final isSel = _selectedIcon == emoji;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = emoji),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primaryAccent : (isDark ? AppColors.darkElevated : AppColors.lightElevated),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel ? AppColors.primaryAccent : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(emoji, style: const TextStyle(fontSize: 22)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _nameController,
                  label: 'Circle Name',
                  hint: 'e.g. TKM Robotics & Drones Club',
                  prefixIcon: Icons.group_work_outlined,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter circle name' : null,
                ),
                const SizedBox(height: 16),
                // Category Dropdown
                Text(
                  'Interest Category',
                  style: AppTypography.labelLarge(
                    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: CollegeData.interestCategories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descController,
                  label: 'Description & Purpose',
                  hint: 'What is this circle about? When do members meet or collaborate?',
                  maxLines: 4,
                  maxLength: 250,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter a description' : null,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppColors.primaryAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Community Moderation: Circles must adhere to TKMCE code of conduct and are actively moderated by student council admins.',
                          style: AppTypography.labelSmall(
                            isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                CustomButton(
                  text: 'Create Circle',
                  width: double.infinity,
                  isLoading: _isLoading,
                  onPressed: _handleSubmit,
                  variant: ButtonVariant.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
