import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/components/tkmingle_scaffold.dart';
import '../../ui/screens/splash/splash_screen.dart';
import '../../ui/screens/auth/welcome_screen.dart';
import '../../ui/screens/auth/login_screen.dart';
import '../../ui/screens/auth/register_screen.dart';
import '../../ui/screens/auth/email_verification_screen.dart';
import '../../ui/screens/auth/profile_creation_screen.dart';
import '../../ui/screens/auth/reset_password_screen.dart';
import '../../ui/screens/discover/discover_screen.dart';
import '../../ui/screens/discover/full_student_profile_screen.dart';
import '../../ui/screens/connections/connection_requests_screen.dart';
import '../../ui/screens/connections/my_connections_screen.dart';
import '../../ui/screens/circles/circles_screen.dart';
import '../../ui/screens/circles/circle_detail_screen.dart';
import '../../ui/screens/circles/create_circle_screen.dart';
import '../../ui/screens/circles/post_discussion_screen.dart';
import '../../ui/screens/tea/spill_the_tea_screen.dart';
import '../../ui/screens/chat/chat_list_screen.dart';
import '../../ui/screens/chat/individual_chat_screen.dart';
import '../../ui/screens/notifications/notifications_screen.dart';
import '../../ui/screens/profile/my_profile_screen.dart';
import '../../ui/screens/profile/edit_profile_screen.dart';
import '../../ui/screens/profile/privacy_settings_screen.dart';
import '../../ui/screens/profile/account_settings_screen.dart';
import '../../ui/screens/admin/admin_dashboard_screen.dart';
import '../../ui/screens/admin/admin_verification_screen.dart';
import '../../ui/screens/admin/admin_moderation_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/verify-email',
      builder: (context, state) => const EmailVerificationScreen(),
    ),
    GoRoute(
      path: '/profile-creation',
      builder: (context, state) => const ProfileCreationScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    // Stateful Bottom Navigation Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return TKMingleScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Discover
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/discover',
              builder: (context, state) => const DiscoverScreen(),
            ),
          ],
        ),
        // Tab 2: Circles
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/circles',
              builder: (context, state) => const CirclesScreen(),
            ),
          ],
        ),
        // Tab 3: Messages
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/messages',
              builder: (context, state) => const ChatListScreen(),
            ),
          ],
        ),
        // Tab 4: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/my-profile',
              builder: (context, state) => const MyProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    // Additional Global Routes
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/tea',
      builder: (context, state) => const SpillTheTeaScreen(),
    ),
    GoRoute(
      path: '/profile/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return FullStudentProfileScreen(userId: id);
      },
    ),
    GoRoute(
      path: '/requests',
      builder: (context, state) => const ConnectionRequestsScreen(),
    ),
    GoRoute(
      path: '/connections',
      builder: (context, state) => const MyConnectionsScreen(),
    ),
    GoRoute(
      path: '/circle/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return CircleDetailScreen(circleId: id);
      },
    ),
    GoRoute(
      path: '/create-circle',
      builder: (context, state) => const CreateCircleScreen(),
    ),
    GoRoute(
      path: '/post/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PostDiscussionScreen(postId: id);
      },
    ),
    GoRoute(
      path: '/chat/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return IndividualChatScreen(conversationId: id);
      },
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/privacy-settings',
      builder: (context, state) => const PrivacySettingsScreen(),
    ),
    GoRoute(
      path: '/account-settings',
      builder: (context, state) => const AccountSettingsScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/verifications',
      builder: (context, state) => const AdminVerificationScreen(),
    ),
    GoRoute(
      path: '/admin/moderation',
      builder: (context, state) => const AdminModerationScreen(),
    ),
  ],
);
