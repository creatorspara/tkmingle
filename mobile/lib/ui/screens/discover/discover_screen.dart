import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/tk_avatars.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/connection_request_model.dart';
import '../../../state/auth_provider.dart';
import '../../../state/discovery_provider.dart';
import '../../../state/connection_provider.dart';
import '../../../state/notification_provider.dart';
import '../../../state/user_provider.dart';
import '../../components/custom_button.dart';
import '../../components/empty_state_view.dart';
import '../../components/interest_chip.dart';
import '../../components/profile_avatar.dart';
import '../../components/skeleton_loader.dart';
import '../../components/status_badge.dart';
import 'discovery_filter_sheet.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref.read(discoveryFiltersProvider.notifier).state =
        ref.read(discoveryFiltersProvider).copyWith(searchQuery: query);
    ref.read(discoveryProvider.notifier).refresh();
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const DiscoveryFilterSheet(),
    );
  }

  Future<void> _handleSurpriseMe() async {
    HapticFeedback.mediumImpact();
    final currentUser = ref.read(authProvider).value;
    if (currentUser == null) return;

    try {
      final surpriseUser = await ref.read(userRepositoryProvider).getRandomEligibleStudent(currentUser.uid);
      if (mounted) {
        _showSurpriseStudentDialog(context, surpriseUser);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception:', '').trim())),
      );
    }
  }

  void _showSurpriseStudentDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.highlight),
              const SizedBox(width: 8),
              Text(
                'Campus Surprise Pick!',
                style: AppTypography.headlineMedium(Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProfileAvatar(
                imageUrl: user.profileImage,
                name: user.name,
                avatarType: user.avatarType,
                avatarId: user.avatarId,
                radius: 44,
                showVerifiedBadge: true,
              ),
              const SizedBox(height: 14),
              Text(
                user.name,
                style: AppTypography.headlineLarge(Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                '${user.department} • ${user.academicYear}',
                style: AppTypography.bodyMedium(AppColors.secondaryAccent),
              ),
              const SizedBox(height: 12),
              Text(
                user.bio,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(AppColors.darkTextSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Maybe Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/profile/${user.uid}');
              },
              child: const Text('View Profile'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(authProvider).value;
    final discoveryState = ref.watch(discoveryProvider);
    final filters = ref.watch(discoveryFiltersProvider);

    final bool hasActiveFilter = filters.department != 'All' ||
        filters.academicYear != 'All' ||
        filters.interest != 'All' ||
        filters.onlyAvailable;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.only(right: 8),
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
                Text(
                  'TKM',
                  style: AppTypography.headlineMedium(
                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ).copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
                ),
                Text(
                  'ingle',
                  style: AppTypography.headlineMedium(AppColors.tkmPurple)
                      .copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
                ),
                const SizedBox(width: 8),
                const StatusBadge(text: 'TKMCE', icon: Icons.school),
              ],
            ),
            Text(
              'Discover Strangers on Campus',
              style: AppTypography.labelSmall(
                isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
        actions: [
          // Connection Requests Button with Badge
          Consumer(
            builder: (context, ref, child) {
              final receivedRequests = ref.watch(receivedRequestsProvider).value ?? [];
              final count = receivedRequests.length;
              return IconButton(
                tooltip: 'Connection Requests',
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  backgroundColor: AppColors.tkmPurple,
                  child: Icon(
                    count > 0 ? Icons.people_alt : Icons.people_alt_outlined,
                    color: count > 0
                        ? AppColors.tkmPurple
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                ),
                onPressed: () => context.push('/requests'),
              );
            },
          ),
          // Notifications / Alerts Button with Badge
          Consumer(
            builder: (context, ref, child) {
              final unreadNotifs = ref.watch(unreadNotificationsCountProvider).value ?? 0;
              return IconButton(
                tooltip: 'Alerts & Notifications',
                icon: Badge(
                  isLabelVisible: unreadNotifs > 0,
                  label: Text('$unreadNotifs'),
                  backgroundColor: AppColors.error,
                  child: Icon(
                    unreadNotifs > 0 ? Icons.notifications : Icons.notifications_none,
                    color: unreadNotifs > 0 ? AppColors.tkmPurple : null,
                  ),
                ),
                onPressed: () => context.push('/notifications'),
              );
            },
          ),
          // Surprise Me Button
          IconButton(
            tooltip: 'Surprise Me with Random Student',
            icon: const Icon(Icons.casino_outlined, color: AppColors.highlight),
            onPressed: _handleSurpriseMe,
          ),
          // Filter Button
          IconButton(
            tooltip: 'Filter Students',
            icon: Badge(
              isLabelVisible: hasActiveFilter,
              backgroundColor: AppColors.primaryAccent,
              smallSize: 8,
              child: const Icon(Icons.tune_rounded),
            ),
            onPressed: _openFilters,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: TextField(
                controller: _searchController,
                onSubmitted: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Search by branch, name, skills, or sports...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            // Incoming Connection Requests Notification Banner
            Consumer(
              builder: (context, ref, child) {
                final receivedRequests = ref.watch(receivedRequestsProvider).value ?? [];
                if (receivedRequests.isEmpty) return const SizedBox.shrink();

                final count = receivedRequests.length;
                final firstReq = receivedRequests.first;
                final senderName = firstReq.sender?.name ?? 'A student';
                final senderDept = firstReq.sender?.department ?? 'TKMCE';

                return Container(
                  margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface : AppColors.lightCardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.tkmPurple.withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.tkmPurple.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.tkmPurple.withOpacity(0.18),
                        ),
                        child: const Icon(
                          Icons.person_add_rounded,
                          color: AppColors.tkmPurple,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  count == 1
                                      ? 'New Connection Request!'
                                      : '$count Connection Requests',
                                  style: AppTypography.titleSmall(
                                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.tkmPurple,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'NEW',
                                    style: AppTypography.labelSmall(Colors.white)
                                        .copyWith(fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              count == 1
                                  ? '$senderName ($senderDept) wants to connect with you.'
                                  : '$senderName and ${count - 1} other${count > 2 ? 's' : ''} sent you a request.',
                              style: AppTypography.bodySmall(
                                isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => context.push('/requests'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tkmPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Review', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Main Discovery View
            Expanded(
              child: discoveryState.when(
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SkeletonLoader(width: 320, height: 420, borderRadius: 24),
                      SizedBox(height: 20),
                      Text('Finding students from other departments...'),
                    ],
                  ),
                ),
                error: (err, _) => Center(
                  child: EmptyStateView(
                    icon: Icons.error_outline,
                    title: 'Could Not Load Students',
                    message: err.toString(),
                    buttonText: 'Try Again',
                    onButtonPressed: () => ref.read(discoveryProvider.notifier).refresh(),
                  ),
                ),
                data: (students) {
                  if (students.isEmpty) {
                    return EmptyStateView(
                      icon: Icons.person_search_outlined,
                      title: 'No Matching Students Right Now',
                      message: hasActiveFilter
                          ? 'Try loosening your department or interest filters to discover more students.'
                          : 'You have viewed all active student cards! Check back soon or reset skipped.',
                      buttonText: hasActiveFilter ? 'Reset Filters' : 'Reset Seen Profiles',
                      onButtonPressed: () {
                        if (hasActiveFilter) {
                          ref.read(discoveryFiltersProvider.notifier).state = const DiscoveryFilters();
                          ref.read(discoveryProvider.notifier).refresh();
                        } else {
                          ref.read(discoveryProvider.notifier).resetSkipped();
                        }
                      },
                    );
                  }

                  // Discover Card Stack View
                  return PageView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _StudentDiscoveryCard(
                        student: student,
                        currentUser: currentUser,
                        onSkip: () => ref.read(discoveryProvider.notifier).skipStudent(student.uid),
                        onBookmark: () => ref.read(discoveryProvider.notifier).toggleSaveStudent(student.uid),
                        isSaved: ref.read(discoveryProvider.notifier).isSaved(student.uid),
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

class _StudentDiscoveryCard extends ConsumerStatefulWidget {
  final UserModel student;
  final UserModel? currentUser;
  final VoidCallback onSkip;
  final VoidCallback onBookmark;
  final bool isSaved;

  const _StudentDiscoveryCard({
    required this.student,
    required this.currentUser,
    required this.onSkip,
    required this.onBookmark,
    required this.isSaved,
  });

  @override
  ConsumerState<_StudentDiscoveryCard> createState() => _StudentDiscoveryCardState();
}

class _StudentDiscoveryCardState extends ConsumerState<_StudentDiscoveryCard> {
  bool _isRequestSent = false;
  bool _isLoading = false;

  Widget _buildHeroAvatar(UserModel student) {
    final effective = (student.avatarId != null && student.avatarId!.isNotEmpty)
        ? student.avatarId!
        : student.profileImage.trim();

    if (TkAvatars.isPreset(effective) || student.avatarType == 'preset') {
      final preset = TkAvatars.getById(student.avatarId ?? effective);
      if (preset != null) {
        return Container(
          color: AppColors.darkBackground,
          padding: const EdgeInsets.all(28),
          alignment: Alignment.center,
          child: Image.asset(
            preset.assetPath,
            fit: BoxFit.contain,
          ),
        );
      }
    } else if (effective.startsWith('http://') || effective.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: effective,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        memCacheWidth: 800,
        placeholder: (context, url) => Container(
          color: AppColors.darkElevated,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.tkmPurple,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildInitialsHero(student),
      );
    }
    return _buildInitialsHero(student);
  }

  Widget _buildInitialsHero(UserModel student) {
    final gradient = TkAvatars.getDeterministicGradient(
      student.name.isNotEmpty ? student.name : student.uid,
    );
    final initials = TkAvatars.getInitials(student.name);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final student = widget.student;

    // Calculate common interests
    final currentInterests = widget.currentUser?.interests ?? [];
    final commonInterests = student.interests.where((i) => currentInterests.contains(i)).toList();

    final connStatusAsync = ref.watch(connectionStatusProvider(student.uid));
    final connStatus = connStatusAsync.value ?? 'none';
    final isConnected = connStatus == 'connected';
    final isPendingSent = connStatus == 'pending_sent' || _isRequestSent;
    final isPendingReceived = connStatus == 'pending_received';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.2,
          ),
        ),
        elevation: 6,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Photo Area
              Stack(
                children: [
                  Container(
                    height: 280,
                    width: double.infinity,
                    decoration: const BoxDecoration(color: AppColors.darkElevated),
                    child: _buildHeroAvatar(student),
                  ),
                  // Dark Gradient Overlay for text legibility
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.85),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Verified Badge & Department info overlay
                  Positioned(
                    top: 14,
                    left: 14,
                    child: StatusBadge(
                      text: student.department,
                      icon: Icons.school_outlined,
                      color: AppColors.secondaryAccent,
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: IconButton(
                      icon: Icon(
                        widget.isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: widget.isSaved ? AppColors.highlight : Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.4),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onBookmark();
                      },
                    ),
                  ),
                  // Name and Batch over photo
                  Positioned(
                    left: 16,
                    bottom: 14,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              student.name.split(' ').first,
                              style: AppTypography.displayMedium(Colors.white).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (student.verified) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.verified, color: AppColors.highlight, size: 20),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${student.department} • ${student.academicYear}',
                          style: AppTypography.labelLarge(AppColors.secondaryAccent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Card Details Body
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Common Interests Pill
                    if (commonInterests.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.highlight.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.highlight.withOpacity(0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt, size: 16, color: AppColors.highlight),
                            const SizedBox(width: 6),
                            Text(
                              '${commonInterests.length} Common Interests with you',
                              style: AppTypography.labelSmall(AppColors.highlight).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    // Social Availability Status
                    if (student.socialAvailability.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primaryAccent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              student.socialAvailability,
                              style: AppTypography.bodyMedium(
                                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ).copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                    // Bio
                    Text(
                      student.bio,
                      style: AppTypography.bodyLarge(
                        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Interests Chips
                    Text(
                      'Interests & Passions',
                      style: AppTypography.titleMedium(
                        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 8,
                      children: student.interests.map((interest) {
                        final isMutual = commonInterests.contains(interest);
                        return InterestChip(
                          label: interest,
                          isMutual: isMutual,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    // Optional Prompts Preview
                    if (student.prompts.isNotEmpty) ...[
                      ...student.prompts.entries.take(1).map((e) {
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.key,
                                style: AppTypography.labelSmall(AppColors.secondaryAccent),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                e.value,
                                style: AppTypography.bodyMedium(
                                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                    ],
                    // Actions Bar (Skip, View Profile, Send Request)
                    Row(
                      children: [
                        // Skip Button
                        IconButton.filledTonal(
                          icon: const Icon(Icons.close_rounded),
                          tooltip: 'Skip',
                          style: IconButton.styleFrom(
                            backgroundColor: isDark ? AppColors.darkElevated : AppColors.lightElevated,
                            foregroundColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            padding: const EdgeInsets.all(14),
                          ),
                          onPressed: widget.onSkip,
                        ),
                        const SizedBox(width: 10),
                        // View Full Profile
                        Expanded(
                          child: CustomButton(
                            text: 'View Full Profile',
                            variant: ButtonVariant.secondary,
                            onPressed: () => context.push('/profile/${student.uid}'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Connect / Connected / Accept Button
                        if (isConnected) ...[
                          IconButton.filled(
                            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
                            tooltip: 'Connected • Message',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.secondaryAccent,
                              padding: const EdgeInsets.all(14),
                            ),
                            onPressed: () {
                              context.push('/profile/${student.uid}');
                            },
                          ),
                        ] else if (isPendingReceived) ...[
                          IconButton.filled(
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                            tooltip: 'Accept Connection Request',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.highlight,
                              padding: const EdgeInsets.all(14),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    HapticFeedback.mediumImpact();
                                    setState(() => _isLoading = true);
                                    final curUser = ref.read(authProvider).value;
                                    if (curUser != null) {
                                      final received = await ref
                                          .read(connectionRepositoryProvider)
                                          .getReceivedRequests(curUser.uid);
                                      final match = received.firstWhere(
                                        (r) => r.senderId == student.uid,
                                        orElse: () => ConnectionRequestModel(
                                          id: '',
                                          senderId: student.uid,
                                          receiverId: curUser.uid,
                                        ),
                                      );
                                      if (match.id.isNotEmpty) {
                                        await ref
                                            .read(connectionRepositoryProvider)
                                            .acceptRequest(match.id);
                                      }
                                      ref.invalidate(connectionStatusProvider(student.uid));
                                      ref.invalidate(myConnectionsProvider);
                                      ref.invalidate(receivedRequestsProvider);
                                    }
                                    if (mounted) {
                                      setState(() => _isLoading = false);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Connected with ${student.name}!'),
                                          backgroundColor: AppColors.success,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ] else ...[
                          IconButton.filled(
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Icon(
                                    isPendingSent ? Icons.hourglass_top_rounded : Icons.person_add_rounded,
                                    color: Colors.white,
                                  ),
                            tooltip: isPendingSent ? 'Request Pending • Tap for options' : 'Send Connection Request',
                            style: IconButton.styleFrom(
                              backgroundColor: isPendingSent ? AppColors.darkTextMuted : AppColors.primaryAccent,
                              padding: const EdgeInsets.all(14),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (isPendingSent) {
                                      _showManageRequestModal(context, student, ref.read(authProvider).value);
                                      return;
                                    }
                                    HapticFeedback.mediumImpact();
                                    setState(() => _isLoading = true);
                                    final curUser = ref.read(authProvider).value;
                                    if (curUser != null) {
                                      await ref
                                          .read(connectionRepositoryProvider)
                                          .sendRequest(curUser.uid, student.uid);
                                      ref.invalidate(connectionStatusProvider(student.uid));
                                      ref.invalidate(sentRequestsProvider);
                                    }
                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                        _isRequestSent = true;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Connection request sent to ${student.name}!'),
                                          backgroundColor: AppColors.success,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showManageRequestModal(BuildContext context, UserModel student, UserModel? curUser) {
    if (curUser == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Connection Request Sent',
                  style: AppTypography.titleLarge(
                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'You requested to connect with ${student.name}. If they haven’t responded, you can resend a notification reminder or cancel the request.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium(
                    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Resend Request (Remind)',
                  icon: Icons.notifications_active_outlined,
                  width: double.infinity,
                  variant: ButtonVariant.primary,
                  onPressed: () async {
                    Navigator.pop(bottomSheetContext);
                    setState(() => _isLoading = true);
                    try {
                      await ref.read(connectionRepositoryProvider).sendRequest(curUser.uid, student.uid);
                      ref.invalidate(connectionStatusProvider(student.uid));
                      ref.invalidate(sentRequestsProvider);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Connection reminder sent to ${student.name}!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Cancel Request',
                  icon: Icons.close_rounded,
                  width: double.infinity,
                  variant: ButtonVariant.secondary,
                  onPressed: () async {
                    Navigator.pop(bottomSheetContext);
                    setState(() => _isLoading = true);
                    try {
                      await ref.read(connectionRepositoryProvider).cancelRequestBetween(curUser.uid, student.uid);
                      ref.invalidate(connectionStatusProvider(student.uid));
                      ref.invalidate(sentRequestsProvider);
                      if (mounted) {
                        setState(() => _isRequestSent = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Connection request cancelled. You can send again anytime.'),
                            backgroundColor: AppColors.darkTextMuted,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
