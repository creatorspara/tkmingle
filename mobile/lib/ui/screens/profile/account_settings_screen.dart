import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/update_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/auth_provider.dart';
import '../../../state/theme_provider.dart';
import '../../components/update_dialog.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  bool _notifRequests = true;
  bool _notifMessages = true;
  bool _notifCircles = true;
  bool _checkingUpdate = false;

  Future<void> _checkForUpdates(BuildContext context) async {
    if (_checkingUpdate) return;
    setState(() => _checkingUpdate = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Checking for new TKMingle updates...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final update = await UpdateService.checkForUpdate(force: true);
      if (!context.mounted) return;
      if (update != null) {
        UpdateDialog.show(context, update);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are on the latest version of TKMingle! (v${UpdateService.currentVersionName})'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not check for updates: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _checkingUpdate = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Preferences'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Appearance Section
            Text(
              'Appearance',
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
              child: SwitchListTile(
                secondary: Icon(
                  themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: AppColors.primaryAccent,
                ),
                title: const Text('Dark Mode Theme'),
                subtitle: Text(themeMode == ThemeMode.dark ? 'Default Navy & Electric Violet' : 'Clean Modern Light'),
                value: themeMode == ThemeMode.dark,
                activeColor: AppColors.primaryAccent,
                onChanged: (_) {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
              ),
            ),
            const SizedBox(height: 24),
            // Notifications Section
            Text(
              'Notification Preferences',
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
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Connection Requests'),
                    subtitle: const Text('Get notified when a peer sends you a connection invite'),
                    value: _notifRequests,
                    activeColor: AppColors.primaryAccent,
                    onChanged: (val) => setState(() => _notifRequests = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Direct Messages'),
                    subtitle: const Text('Real-time alerts for incoming chat messages'),
                    value: _notifMessages,
                    activeColor: AppColors.primaryAccent,
                    onChanged: (val) => setState(() => _notifMessages = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Circle Announcements'),
                    subtitle: const Text('Activity and new discussions in joined circles'),
                    value: _notifCircles,
                    activeColor: AppColors.primaryAccent,
                    onChanged: (val) => setState(() => _notifCircles = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // App Updates Section
            Text(
              'App Updates & Releases',
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
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.system_update_rounded, color: AppColors.primaryAccent, size: 20),
                ),
                title: const Text('Check for Updates'),
                subtitle: const Text('v${UpdateService.currentVersionName} (Build ${UpdateService.currentVersionCode}) • Tap to check latest release'),
                trailing: _checkingUpdate
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryAccent),
                      )
                    : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.darkTextMuted),
                onTap: () => _checkForUpdates(context),
              ),
            ),
            const SizedBox(height: 24),
            // Danger Zone
            Text(
              'Account Management',
              style: AppTypography.titleMedium(AppColors.error),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: AppColors.error),
                    title: const Text('Delete Account & Campus Data', style: TextStyle(color: AppColors.error)),
                    subtitle: const Text('Permanently remove your profile and message history'),
                    onTap: () => _showDeleteAccountDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppColors.primaryAccent),
                    title: const Text('Log Out'),
                    onTap: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/welcome');
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                '${AppConstants.appName} v${UpdateService.currentVersionName} • ${AppConstants.collegeShort}',
                style: AppTypography.labelSmall(AppColors.darkTextMuted),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Student Account?'),
          content: const Text(
            'This action will permanently delete your profile, connections, and message history from TKMingle. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/welcome');
                }
              },
              child: const Text('Delete My Data', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
