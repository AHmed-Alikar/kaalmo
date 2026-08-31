import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_state.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import '../../features/campaigns/presentation/campaign_comments_screen.dart';
import '../../features/campaigns/presentation/campaign_details_screen.dart';
import '../../features/campaigns/presentation/campaign_supporters_screen.dart';
import '../../features/campaigns/presentation/campaign_updates_screen.dart';
import '../../features/campaigns/presentation/explore_screen.dart';
import '../../features/beneficiary/presentation/beneficiary_dashboard_screen.dart';
import '../../features/donations/presentation/donate_flow_screen.dart';
import '../../features/donations/presentation/donation_detail_screen.dart';
import '../../features/donations/presentation/my_donations_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/organizer/presentation/campaign_edit_screen.dart';
import '../../features/organizer/presentation/campaign_manage_screen.dart';
import '../../features/organizer/presentation/my_campaigns_screen.dart';
import '../../features/organizer/presentation/organizer_dashboard_screen.dart';
import '../../features/organizer/presentation/organizer_invites_screen.dart';
import '../../features/organizer/presentation/post_update_screen.dart';
import '../../features/profile/presentation/about_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/support/presentation/create_ticket_screen.dart';
import '../../features/support/presentation/support_screen.dart';
import '../../features/support/presentation/ticket_detail_screen.dart';
import '../../shared/widgets/not_found_screen.dart';
import '../di/providers.dart';
import 'app_routes.dart';
import 'main_shell.dart';

/// Rebuilds GoRouter's redirect whenever auth state changes.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    _sub = ref.listen<AuthState>(authControllerProvider, (_, _) => notifyListeners());
  }

  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final path = state.matchedLocation;

      if (!auth.isResolved) {
        return path == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final isPublic =
          AppRoutes.publicPaths.contains(path) || path.startsWith('/campaign/');

      if (auth.isAuthenticated) {
        final needsVerify = auth.user?.emailVerified == false;
        if (needsVerify) {
          return path == AppRoutes.verifyEmail ? null : AppRoutes.verifyEmail;
        }
        if (AppRoutes.authOnlyGuestPaths.contains(path)) {
          // Come back to the in-app destination the user was trying to reach.
          final from = state.uri.queryParameters['from'];
          const returnable = [
            '/campaign/', '/profile/', '/organizer', '/beneficiary', '/notifications', '/support'
          ];
          if (from != null && returnable.any(from.startsWith)) return from;
          return AppRoutes.home;
        }
        if (path == AppRoutes.splash) return AppRoutes.home;
        return null;
      }

      if (path == AppRoutes.splash) return AppRoutes.login;
      return isPublic ? null : AppRoutes.login;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (_, _) => const RegisterScreen()),
      GoRoute(path: AppRoutes.forgotPassword, builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (_, state) => ResetPasswordScreen(
          initialEmail: state.uri.queryParameters['email'],
        ),
      ),
      GoRoute(path: AppRoutes.verifyEmail, builder: (_, _) => const VerifyEmailScreen()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellKey,
            routes: [GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.explore,
                builder: (_, state) => ExploreScreen(
                  initialCategory: state.uri.queryParameters['category'],
                  autofocusSearch: state.uri.queryParameters['focus'] == '1',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, _) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'donations',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const MyDonationsScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        parentNavigatorKey: _rootKey,
                        builder: (_, state) =>
                            DonationDetailScreen(donationId: state.pathParameters['id']!),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'settings',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const SettingsScreen(),
                    routes: [
                      GoRoute(
                        path: 'about',
                        parentNavigatorKey: _rootKey,
                        builder: (_, _) => const AboutScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.campaignDetail,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => CampaignDetailsScreen(campaignId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'donate',
            parentNavigatorKey: _rootKey,
            builder: (_, state) => DonateFlowScreen(campaignId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'updates',
            parentNavigatorKey: _rootKey,
            builder: (_, state) => CampaignUpdatesScreen(campaignId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'comments',
            parentNavigatorKey: _rootKey,
            builder: (_, state) => CampaignCommentsScreen(campaignId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'supporters',
            parentNavigatorKey: _rootKey,
            builder: (_, state) => CampaignSupportersScreen(campaignId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.organizer,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const OrganizerDashboardScreen(),
        routes: [
          GoRoute(
            path: 'campaigns',
            parentNavigatorKey: _rootKey,
            builder: (_, _) => const MyCampaignsScreen(),
          ),
          GoRoute(
            path: 'invites',
            parentNavigatorKey: _rootKey,
            builder: (_, _) => const OrganizerInvitesScreen(),
          ),
          GoRoute(
            path: 'campaign/:id',
            parentNavigatorKey: _rootKey,
            builder: (_, state) => CampaignManageScreen(campaignId: state.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'edit',
                parentNavigatorKey: _rootKey,
                builder: (_, state) => CampaignEditScreen(campaignId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'update',
                parentNavigatorKey: _rootKey,
                builder: (_, state) => PostUpdateScreen(campaignId: state.pathParameters['id']!),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.beneficiary,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const BeneficiaryDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.support,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const SupportScreen(),
        routes: [
          GoRoute(
            path: 'new',
            parentNavigatorKey: _rootKey,
            builder: (_, state) =>
                CreateTicketScreen(initialSubject: state.uri.queryParameters['subject']),
          ),
          GoRoute(
            path: ':id',
            parentNavigatorKey: _rootKey,
            builder: (_, state) => TicketDetailScreen(ticketId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
    errorBuilder: (_, _) => const NotFoundScreen(),
  );
});
