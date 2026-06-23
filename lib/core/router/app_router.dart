import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rsc_rider/core/router/route_guards.dart';
import 'package:rsc_rider/core/router/route_names.dart';
import 'package:rsc_rider/features/auth/presentation/login_screen.dart';
import 'package:rsc_rider/features/auth/presentation/splash_screen.dart';
import 'package:rsc_rider/features/dashboard/presentation/dashboard_screen.dart';
import 'package:rsc_rider/features/delivery/presentation/active_delivery_screen.dart';
import 'package:rsc_rider/features/dispatch/presentation/incoming_request_screen.dart';
import 'package:rsc_rider/features/history/presentation/history_screen.dart';
import 'package:rsc_rider/features/notifications/presentation/notifications_screen.dart';
import 'package:rsc_rider/features/profile/presentation/profile_screen.dart';

class AppRouter {
  AppRouter(this._authNotifier);

  final AuthNotifier _authNotifier;

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: _authNotifier,
    redirect: _redirect,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // ── Main shell with bottom nav ───────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.notifications,
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Full-screen flows — no bottom nav ────────────────────────────────
      GoRoute(
        path: RouteNames.incomingRequest,
        builder: (context, state) => const IncomingRequestScreen(),
      ),
      GoRoute(
        path: RouteNames.activeDelivery,
        builder: (context, state) => const ActiveDeliveryScreen(),
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    // Wait for the initial secure-storage read to complete.
    if (!_authNotifier.isInitialized) return null;

    final isAuth = _authNotifier.isAuthenticated;
    final location = state.matchedLocation;

    // Splash is a loading gate only — always redirect away once initialized.
    if (location == RouteNames.splash) {
      return isAuth ? RouteNames.dashboard : RouteNames.login;
    }

    if (!isAuth && location != RouteNames.login) return RouteNames.login;
    if (isAuth && location == RouteNames.login) return RouteNames.dashboard;

    return null;
  }
}

// ── Bottom navigation shell ────────────────────────────────────────────────────

class _AppShell extends StatelessWidget {
  const _AppShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: shell.goBranch,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications_rounded),
              label: 'Alerts',
            ),
          ],
        ),
      );
}
