import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/auth_provider.dart';
import '../../components/custom_button.dart';
import '../../components/custom_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'abhiram.v@tkmce.ac.in');
  final _passwordController = TextEditingController(text: 'Password123!');
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
      final user = ref.read(authProvider).value;
      if (mounted) {
        if (user != null && user.isAdmin) {
          context.go('/admin');
        } else {
          context.go('/discover');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _quickFill(String email) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = 'TKMingleDemo#2026';
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.secondaryBackground,
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset('assets/images/app_icon.png', fit: BoxFit.cover),
              ),
            ),
            const Text('Login to TKMingle'),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!',
                  style: AppTypography.displayMedium(
                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Access your exclusive TKMCE campus discovery network.',
                  style: AppTypography.bodyMedium(
                    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTypography.bodyMedium(AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                CustomTextField(
                  controller: _emailController,
                  label: 'College / Institutional Email',
                  hint: 'name@tkmce.ac.in',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter your email';
                    if (!val.contains('@')) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('@tkmce.ac.in'),
                      onPressed: () {
                        final current = _emailController.text.trim();
                        final prefix = current.contains('@') ? current.split('@').first : current;
                        if (prefix.isNotEmpty) {
                          _emailController.text = '$prefix@tkmce.ac.in';
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (val) {
                    if (val == null || val.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showForgotPasswordDialog(context),
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Log In',
                  width: double.infinity,
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                  variant: ButtonVariant.primary,
                ),
                const SizedBox(height: 28),
                // Demo Quick Fill section
                Container(
                  padding: const EdgeInsets.all(14),
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
                          const Icon(Icons.bolt, size: 18, color: AppColors.highlight),
                          const SizedBox(width: 6),
                          Text(
                            'Quick Demo Accounts',
                            style: AppTypography.titleMedium(
                              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: () => _quickFill('arjun.k@tkmce.ac.in'),
                            child: const Text('Arjun (CSE)'),
                          ),
                          OutlinedButton(
                            onPressed: () => _quickFill('sneha.varma@tkmce.ac.in'),
                            child: const Text('Sneha (ECE)'),
                          ),
                          OutlinedButton(
                            onPressed: () => _quickFill('rahul.menon@tkmce.ac.in'),
                            child: const Text('Rahul (ME)'),
                          ),
                          OutlinedButton(
                            onPressed: () => _quickFill('admin@tkmce.ac.in'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.highlightWarm,
                              side: const BorderSide(color: AppColors.highlightWarm),
                            ),
                            child: const Text('Campus Admin'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: AppTypography.bodyMedium(
                        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('Register Here'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailCtrl = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your college email address to receive password recovery instructions.'),
              const SizedBox(height: 16),
              CustomTextField(
                controller: emailCtrl,
                label: 'Email',
                hint: 'name@tkmce.ac.in',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset instructions sent to your college email.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Send Reset Link'),
            ),
          ],
        );
      },
    );
  }
}
