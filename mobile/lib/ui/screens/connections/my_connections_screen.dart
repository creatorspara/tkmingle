import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/auth_provider.dart';
import '../../../state/connection_provider.dart';
import '../../../state/chat_provider.dart';
import '../../components/empty_state_view.dart';
import '../../components/profile_avatar.dart';

class MyConnectionsScreen extends ConsumerStatefulWidget {
  const MyConnectionsScreen({super.key});

  @override
  ConsumerState<MyConnectionsScreen> createState() => _MyConnectionsScreenState();
}

class _MyConnectionsScreenState extends ConsumerState<MyConnectionsScreen> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(authProvider).value;
    final connectionsAsync = ref.watch(myConnectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Campus Connections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined),
            tooltip: 'Pending Requests',
            onPressed: () => context.push('/requests'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _search = val.trim().toLowerCase()),
                decoration: const InputDecoration(
                  hintText: 'Search connections by name or department...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            Expanded(
              child: connectionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (connections) {
                  final filtered = connections.where((c) {
                    final other = c.otherUser;
                    if (other == null) return false;
                    if (_search.isEmpty) return true;
                    return other.name.toLowerCase().contains(_search) ||
                        other.department.toLowerCase().contains(_search);
                  }).toList();

                  if (filtered.isEmpty) {
                    return EmptyStateView(
                      icon: Icons.people_outline,
                      title: 'No Connections Yet',
                      message: 'Discover other TKMCE students and send them requests to start chatting.',
                      buttonText: 'Discover Students',
                      onButtonPressed: () => context.go('/discover'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final conn = filtered[index];
                      final other = conn.otherUser!;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ProfileAvatar(
                                imageUrl: other.profileImage,
                                name: other.name,
                                radius: 26,
                                showVerifiedBadge: other.verified,
                                onTap: () => context.push('/profile/${other.uid}'),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      other.name,
                                      style: AppTypography.titleMedium(
                                        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${other.department} • ${other.academicYear}',
                                      style: AppTypography.bodyMedium(AppColors.secondaryAccent),
                                    ),
                                    if (other.socialAvailability.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        other.socialAvailability,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.labelSmall(AppColors.highlight),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton.filledTonal(
                                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.primaryAccent.withOpacity(0.18),
                                  foregroundColor: AppColors.primaryAccent,
                                ),
                                onPressed: () async {
                                  if (currentUser == null) return;
                                  final conv = await ref
                                      .read(messageRepositoryProvider)
                                      .getOrCreateConversation(currentUser.uid, other.uid);
                                  if (context.mounted) {
                                    context.push('/chat/${conv.conversationId}');
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
