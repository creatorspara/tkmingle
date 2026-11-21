import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/report_model.dart';
import '../../../state/auth_provider.dart';
import '../../../state/user_provider.dart';
import '../../../state/discovery_provider.dart';
import '../../components/custom_button.dart';
import '../../components/custom_text_field.dart';

class ReportBlockSheet extends ConsumerStatefulWidget {
  final String targetUserId;
  final String targetUserName;

  const ReportBlockSheet({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
  });

  @override
  ConsumerState<ReportBlockSheet> createState() => _ReportBlockSheetState();
}

class _ReportBlockSheetState extends ConsumerState<ReportBlockSheet> {
  final _detailsController = TextEditingController();
  String _selectedReason = 'Inappropriate messages or harassment';
  bool _isSubmitting = false;

  final List<String> _reportReasons = [
    'Inappropriate messages or harassment',
    'Impersonating another TKMCE student',
    'Not an authentic TKMCE student',
    'Spam, advertising, or suspicious links',
    'Offensive language or hate speech',
    'Other safety concern',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _handleReport() async {
    setState(() => _isSubmitting = true);
    final currentUser = ref.read(authProvider).value;

    final report = ReportModel(
      id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
      reporterId: currentUser?.uid ?? 'anon',
      reporterName: currentUser?.name ?? 'Student',
      reportedUserId: widget.targetUserId,
      reportedUserName: widget.targetUserName,
      reason: _selectedReason,
      details: _detailsController.text.trim(),
    );

    await ref.read(userRepositoryProvider).reportUser(report);

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted to TKMCE Student Council for review.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _handleBlock() async {
    final currentUser = ref.read(authProvider).value;
    if (currentUser != null) {
      await ref.read(userRepositoryProvider).blockUser(currentUser.uid, widget.targetUserId);
      ref.read(discoveryProvider.notifier).refresh();
    }
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.targetUserName} has been blocked and removed from your discovery.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Safety & Moderation Options',
                style: AppTypography.headlineMedium(
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Managing interactions with ${widget.targetUserName}',
                style: AppTypography.bodyMedium(
                  isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Reason for Report',
                style: AppTypography.labelLarge(
                  isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedReason,
                isExpanded: true,
                items: _reportReasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedReason = val);
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _detailsController,
                label: 'Additional Context (Optional)',
                hint: 'Describe what happened...',
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Submit Report to Admin',
                width: double.infinity,
                isLoading: _isSubmitting,
                onPressed: _handleReport,
                variant: ButtonVariant.primary,
              ),
              const SizedBox(height: 14),
              CustomButton(
                text: 'Block ${widget.targetUserName.split(' ').first}',
                width: double.infinity,
                onPressed: _handleBlock,
                variant: ButtonVariant.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
