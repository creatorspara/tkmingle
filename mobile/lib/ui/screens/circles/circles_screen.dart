import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/college_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/circle_model.dart';
import '../../../state/auth_provider.dart';
import '../../../state/circle_provider.dart';
import '../../components/empty_state_view.dart';
import '../../components/interest_chip.dart';
import '../../components/status_badge.dart';

class CirclesScreen extends ConsumerStatefulWidget {
  const CirclesScreen({super.key});

  @override
  ConsumerState<CirclesScreen> createState() => _CirclesScreenState();
}

class _CirclesScreenState extends ConsumerState<CirclesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(authProvider).value;
    final selectedCat = ref.watch(circleCategoryFilterProvider);
    final allCirclesAsync = ref.watch(circlesListProvider);
    final joinedCirclesAsync = ref.watch(joinedCirclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                color: isDark ? AppColors.tkmPurple.withOpacity(0.12) : AppColors.tkmPurple.withOpacity(0.08),
                border: Border.all(
                  color: isDark ? AppColors.tkmPurple.withOpacity(0.3) : AppColors.tkmPurple.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Image.asset('assets/images/app_icon.png', fit: BoxFit.contain),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Campus Circles',
                  style: AppTypography.headlineLarge(
                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  'Interest-Based TKMCE Communities',
                  style: AppTypography.labelSmall(
                    isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Create New Circle',
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryAccent),
            onPressed: () => context.push('/create-circle'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryAccent,
          labelColor: AppColors.primaryAccent,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          tabs: const [
            Tab(text: 'Explore All Circles'),
            Tab(text: 'My Circles'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  ref.read(circleSearchProvider.notifier).state = val;
                },
                decoration: const InputDecoration(
                  hintText: 'Search circles (e.g. Football, Robotics, Music)...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            // Category Chips Carousel
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: ['All', ...CollegeData.interestCategories].map((cat) {
                  final isSel = selectedCat == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InterestChip(
                      label: cat,
                      isSelected: isSel,
                      onTap: () {
                        ref.read(circleCategoryFilterProvider.notifier).state = cat;
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: All Circles
                  allCirclesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                    data: (circles) {
                      if (circles.isEmpty) {
                        return const EmptyStateView(
                          icon: Icons.groups_outlined,
                          title: 'No Circles Found',
                          message: 'No active campus circles match your filter. Be the first to start one!',
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: circles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final circle = circles[index];
                          return _CircleCard(
                            circle: circle,
                            currentUserId: currentUser?.uid,
                          );
                        },
                      );
                    },
                  ),
                  // Tab 2: Joined Circles
                  joinedCirclesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                    data: (joined) {
                      if (joined.isEmpty) {
                        return EmptyStateView(
                          icon: Icons.group_add_outlined,
                          title: 'You Haven\'t Joined Any Circles',
                          message: 'Explore communities matching your hobbies and collaborate with students across branches.',
                          buttonText: 'Browse Communities',
                          onButtonPressed: () => _tabController.animateTo(0),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: joined.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final circle = joined[index];
                          return _CircleCard(
                            circle: circle,
                            currentUserId: currentUser?.uid,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryAccent,
        icon: const Icon(Icons.group_add_rounded, color: Colors.white),
        label: const Text('Start Circle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        onPressed: () => context.push('/create-circle'),
      ),
    );
  }
}

class _CircleCard extends ConsumerWidget {
  final CircleModel circle;
  final String? currentUserId;

  const _CircleCard({
    required this.circle,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push('/circle/${circle.circleId}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(circle.icon, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          circle.name,
                          style: AppTypography.titleMedium(
                            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            StatusBadge(
                              text: circle.category,
                              color: AppColors.secondaryAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${circle.memberCount} members',
                              style: AppTypography.labelSmall(
                                isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Join / Leave Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: circle.isMember
                          ? (isDark ? AppColors.darkElevated : AppColors.lightElevated)
                          : AppColors.primaryAccent,
                      foregroundColor: circle.isMember
                          ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                          : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (currentUserId == null) return;
                      final repo = ref.read(circleRepositoryProvider);
                      if (circle.isMember) {
                        await repo.leaveCircle(circle.circleId, currentUserId!);
                      } else {
                        await repo.joinCircle(circle.circleId, currentUserId!);
                      }
                      ref.invalidate(circlesListProvider);
                      ref.invalidate(joinedCirclesProvider);
                    },
                    child: Text(circle.isMember ? 'Joined' : 'Join'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                circle.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium(
                  isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
