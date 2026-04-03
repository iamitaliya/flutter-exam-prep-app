import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/topics/presentation/topic_list_screen.dart';
import '../../features/exam/presentation/question_screen.dart';
import '../../features/exam/presentation/results_screen.dart';
import '../../features/exam/presentation/review_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../constants/app_colors.dart';
import 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final settings = ref.watch(userSettingsProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final isOnboarded = settings.onboardingComplete;
      final path = state.uri.path;

      if (path == RouteNames.splash) return null;

      if (!isOnboarded && path != RouteNames.onboarding) {
        return RouteNames.onboarding;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.exam,
        builder: (context, state) {
          final topicId = state.pathParameters['topicId'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          return QuestionScreen(
            topicId: topicId,
            reviewIds: extra?['reviewIds'] as List<String>?,
          );
        },
      ),
      GoRoute(
        path: RouteNames.results,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ResultsScreen(sessionId: extra?['sessionId'] as String? ?? '');
        },
      ),
      GoRoute(
        path: RouteNames.review,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ReviewScreen(
            sessionId: extra?['sessionId'] as String? ?? '',
          );
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return _ScaffoldWithBottomNav(child: child, state: state);
        },
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.topics,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TopicListScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

class _ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const _ScaffoldWithBottomNav({required this.child, required this.state});

  int _currentIndex(String path) {
    if (path.startsWith(RouteNames.topics)) return 1;
    if (path.startsWith(RouteNames.settings)) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = state.uri.path;
    final currentIndex = _currentIndex(currentPath);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go(RouteNames.dashboard);
                break;
              case 1:
                context.go(RouteNames.topics);
                break;
              case 2:
                context.go(RouteNames.settings);
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book_rounded),
              label: 'Topics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
