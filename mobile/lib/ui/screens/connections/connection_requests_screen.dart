import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/connection_provider.dart';
import '../../components/empty_state_view.dart';
import '../../components/profile_avatar.dart';

class ConnectionRequestsScreen extends ConsumerStatefulWidget {
  const ConnectionRequestsScreen({super.key});

  @override
  ConsumerState<ConnectionRequestsScreen> createState() => _ConnectionRequestsScreenState();
}

class _ConnectionRequestsScreenState extends ConsumerState<ConnectionRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final receivedAsync = ref.watch(receivedRequestsProvider);
    final sentAsync = ref.watch(sentRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Requests'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryAccent,
          labelColor: AppColors.primaryAccent,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Received'),
                  if (receivedAsync.value != null && receivedAsync.value!.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: AppColors.primaryAccent,
                      child: Text(
                        '${receivedAsync.value!.length}',
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Sent'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Received Tab
          receivedAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (requests) {
              if (requests.isEmpty) {
                return const EmptyStateView(
                  icon: Icons.inbox_outlined,
                  title: 'No Pending Received Requests',
                  message: 'When other students at TKMCE send you connection requests, they will appear here.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final req = requests[index];
                  final sender = req.sender;
                  if (sender == null) return const SizedBox.shrink();

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ProfileAvatar(
                                imageUrl: sender.profileImage,
                                name: sender.name,
                                radius: 24,
                                showVerifiedBadge: sender.verified,
                                onTap: () => context.push('/profile/${sender.uid}'),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sender.name,
                                      style: AppTypography.titleMedium(
                                        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${sender.department} • ${sender.academicYear}',
                                      style: AppTypography.bodyMedium(AppColors.secondaryAccent),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (sender.bio.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              sender.bio,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMedium(
                                isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await ref.read(connectionRepositoryProvider).declineRequest(req.id);
                                    ref.invalidate(receivedRequestsProvider);
                                  },
                                  child: const Text('Decline'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryAccent),
                                  onPressed: () async {
                                    await ref.read(connectionRepositoryProvider).acceptRequest(req.id);
                                    ref.invalidate(receivedRequestsProvider);
                                    ref.invalidate(myConnectionsProvider);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Connected with ${sender.name}!'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Accept', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // Sent Tab
          sentAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (requests) {
              if (requests.isEmpty) {
                return const EmptyStateView(
                  icon: Icons.send_outlined,
                  title: 'No Pending Sent Requests',
                  message: 'Students you invite to connect from Discover will appear here until they accept.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final req = requests[index];
                  final receiver = req.receiver;
                  if (receiver == null) return const SizedBox.shrink();

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: ListTile(
                      leading: ProfileAvatar(
                        imageUrl: receiver.profileImage,
                        name: receiver.name,
                        radius: 22,
                        showVerifiedBadge: receiver.verified,
                      ),
                      title: Text(receiver.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${receiver.department} • ${receiver.academicYear}'),
                      trailing: TextButton(
                        onPressed: () async {
                          await ref.read(connectionRepositoryProvider).cancelRequest(req.id);
                          ref.invalidate(sentRequestsProvider);
                        },
                        child: const Text('Cancel', style: TextStyle(color: AppColors.darkTextMuted)),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
