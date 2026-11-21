import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/auth_provider.dart';
import '../../../state/user_provider.dart';
import '../../../state/discovery_provider.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  late bool _discoverable;
  bool _showOnlineStatus = true;
  bool _readReceipts = true;
  bool _crossBranchRequests = true;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).value;
    _discoverable = user?.discoverable ?? true;
  }

  Future<void> _toggleDiscoverable(bool val) async {
    setState(() => _discoverable = val);
    final user = ref.read(authProvider).value;
    if (user != null) {
      await ref.read(userRepositoryProvider).setDiscoverability(user.uid, val);
      final updated = user.copyWith(discoverable: val);
      await ref.read(authProvider.notifier).updateProfile(updated);
      ref.read(discoveryProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Visibility'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Text(
              'Discovery Controls',
              style: AppTypography.titleMedium(AppColors.secondaryAccent),
            ),
            const SizedBox(height: 10),
            // Discoverability Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Student Discoverability',
                        style: AppTypography.titleMedium(
                          isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      subtitle: Text(
                        _discoverable
                            ? 'Your profile card is actively visible to eligible TKMCE students in Discover.'
                            : 'Paused: Other students cannot find you in Discover right now.',
                        style: AppTypography.bodyMedium(
                          isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      value: _discoverable,
                      activeColor: AppColors.highlight,
                      onChanged: _toggleDiscoverable,
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Allow Cross-Department Requests'),
                      subtitle: const Text('Students from all 10 engineering branches can discover and connect with you.'),
                      value: _crossBranchRequests,
                      activeColor: AppColors.primaryAccent,
                      onChanged: (val) => setState(() => _crossBranchRequests = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Messaging & Status Privacy',
              style: AppTypography.titleMedium(AppColors.secondaryAccent),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Show Campus Activity Indicator'),
                      subtitle: const Text('Display an active green badge when you are using the app.'),
                      value: _showOnlineStatus,
                      activeColor: AppColors.highlight,
                      onChanged: (val) => setState(() => _showOnlineStatus = val),
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Read Receipts'),
                      subtitle: const Text('Let connected peers know when you have read their messages.'),
                      value: _readReceipts,
                      activeColor: AppColors.primaryAccent,
                      onChanged: (val) => setState(() => _readReceipts = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Data & Safety Commitments',
              style: AppTypography.titleMedium(AppColors.secondaryAccent),
            ),
            const SizedBox(height: 10),
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
                      const Icon(Icons.shield_outlined, color: AppColors.highlight, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'What TKMingle Never Shares',
                        style: AppTypography.titleMedium(
                          isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const _BulletText('Phone numbers and personal emails are never publicly visible.'),
                  const _BulletText('Zero background GPS tracking or exact coordinate logging.'),
                  const _BulletText('Anonymous direct messaging is prohibited to prevent cyberbullying.'),
                  const _BulletText('All accounts are vetted against authentic college student records.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;

  const _BulletText(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.highlight, fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium(
                isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
