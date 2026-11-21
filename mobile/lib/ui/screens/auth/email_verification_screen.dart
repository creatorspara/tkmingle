import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/auth_provider.dart';
import '../../components/custom_button.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  Future<void> _handleVerify() async {
    final otp = _currentOtp;
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits of the OTP.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final success = await ref.read(authProvider.notifier).verifyEmailOtp(otp);
      if (success && mounted) {
        context.push('/profile-creation');
      } else {
        setState(() => _errorMessage = 'Invalid OTP. For demo mode, enter any 6 digits (e.g. 123456).');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Verification error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  void _fillDemoOtp() {
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = '${i + 1}';
    }
    setState(() => _errorMessage = null);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).value;
    final email = user?.email ?? 'your college email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Campus Email'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  size: 38,
                  color: AppColors.primaryAccent,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Student Verification Code',
                style: AppTypography.headlineLarge(
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We sent a 6-digit verification code to:\n$email',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(
                  isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium(AppColors.error),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              // 6 Digit OTP fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 46,
                    height: 56,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: AppTypography.headlineLarge(
                        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (val.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (_currentOtp.length == 6) {
                          _handleVerify();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              // Demo autofill chip
              ActionChip(
                avatar: const Icon(Icons.flash_on, size: 16, color: AppColors.highlight),
                label: const Text('Auto-fill Demo Code (123456)'),
                onPressed: _fillDemoOtp,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Verify & Continue',
                width: double.infinity,
                isLoading: _isVerifying,
                onPressed: _handleVerify,
                variant: ButtonVariant.primary,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('A new 6-digit code has been sent to your email.')),
                  );
                },
                child: const Text('Resend Verification Code'),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.badge_outlined, size: 18),
                label: const Text('Upload College ID Card instead'),
                onPressed: () => _showManualUploadSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showManualUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manual Campus Verification',
                style: AppTypography.headlineMedium(Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'If you do not have immediate access to your college email inbox, upload a photo of your physical TKMCE student ID card or semester fee receipt for admin verification.',
                style: AppTypography.bodyMedium(AppColors.darkTextSecondary),
              ),
              const SizedBox(height: 20),
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.darkElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.darkBorder, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo_outlined, size: 36, color: AppColors.primaryAccent),
                    const SizedBox(height: 10),
                    Text(
                      'Tap to capture or choose ID photo',
                      style: AppTypography.bodyMedium(AppColors.darkTextSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Submit to Admin Council',
                width: double.infinity,
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ID Card submitted! Admin review is in progress.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.push('/profile-creation');
                },
                variant: ButtonVariant.primary,
              ),
            ],
          ),
        );
      },
    );
  }
}
