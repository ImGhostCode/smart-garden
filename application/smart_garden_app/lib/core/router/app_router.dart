import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/garden/presentation/screens/create_garden_screen.dart';
import '../../features/garden/presentation/screens/garden_detail_screen.dart';
import '../../features/home/presentation/screens/app_skeleton.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notification_client/presentation/screens/notification_client_screen.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/water_routine/presentation/screens/water_routine_screen.dart';
import '../../features/water_schedule/presentation/screens/water_schedule_screen.dart';
import '../../features/weather_client/presentation/screens/weather_client_screen.dart';
import '../constants/app_constants.dart';
import 'app_routers.dart';

final _shellNavigatorKey = GlobalKey<NavigatorState>();
final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final isFirstTime = ref.watch(onboardingProvider);
  // Watch for locale changes - this rebuilds the router when locale changes
  // ref.watch(persistentLocaleProvider);

  // // Create a router with locale awareness
  final listenable = ValueNotifier<bool>(authState.isAuthenticated);
  ref.listen(
    authProvider,
    (_, next) => listenable.value = next.isAuthenticated,
  );
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppConstants.initialRoute,
    debugLogDiagnostics: true,
    // Add the observer for locale awareness
    // observers: [ref.read(localizationRouterObserverProvider)],
    refreshListenable: listenable,
    redirect: (context, state) =>
        authGuard(context, state, authState, isFirstTime),
    routes: [
      GoRoute(
        path: AppConstants.onboardingRoute,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppConstants.settingsRoute,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      ...AppRoutes.authRoutes,

      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppSkeleton(child: child),
        routes: [
          GoRoute(
            path: AppConstants.gardenRoute,
            name: RouteNames.garden,
            pageBuilder: (context, state) => fadeTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
            ),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.createGarden,
                builder: (context, state) => const CreateGardenScreen(),
              ),
              GoRoute(
                path: ":gardenId",
                name: RouteNames.gardenDetail,
                builder: (context, state) => GardenDetailScreen(
                  gardenId: state.pathParameters['gardenId']!,
                ),
                routes: AppRoutes.gardenSubRoutes,
              ),
            ],
          ),
          GoRoute(
            path: AppConstants.waterScheduleRoute,
            name: RouteNames.waterSchedules,
            pageBuilder: (context, state) => fadeTransitionPage(
              key: state.pageKey,
              child: const WaterScheduleScreen(),
            ),
            routes: AppRoutes.wsSubRoutes,
          ),
          GoRoute(
            path: AppConstants.weatherClientRoute,
            name: RouteNames.weatherClients,
            pageBuilder: (context, state) => fadeTransitionPage(
              key: state.pageKey,
              child: const WeatherClientScreen(),
            ),
            routes: AppRoutes.wcSubRoutes,
          ),
          GoRoute(
            path: AppConstants.notificationClientRoute,
            name: RouteNames.notificationClients,
            pageBuilder: (context, state) => fadeTransitionPage(
              key: state.pageKey,
              child: const NotificationClientScreen(),
            ),
            routes: AppRoutes.ncSubRoutes,
          ),
          GoRoute(
            path: AppConstants.waterRoutineRoute,
            name: RouteNames.waterRoutines,
            pageBuilder: (context, state) => fadeTransitionPage(
              key: state.pageKey,
              child: const WaterRoutineScreen(),
            ),
            routes: AppRoutes.wrSubRoutes,
          ),
        ],
      ),

      GoRoute(
        path: '/',
        builder: (context, state) {
          if (authState.isCheckingStatus) {
            return const SplashScreen();
          }
          return const SizedBox();
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '404',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Page ${state.uri.path} not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.gardenRoute),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

Page<dynamic> fadeTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
        child: child,
      );
    },
  );
}

String? authGuard(
  BuildContext context,
  GoRouterState state,
  AuthState authState,
  bool isFirstTime,
) {
  // If it is checking login status, do not redirect; keep it at '/'.
  if (authState.isCheckingStatus) {
    return null;
  }

  final isLoggedIn = authState.isAuthenticated;
  final isGoingToInitial = state.matchedLocation == AppConstants.initialRoute;
  final isGoingToOnboarding =
      state.matchedLocation == AppConstants.onboardingRoute;
  final isGoingToLogin = state.matchedLocation == AppConstants.loginRoute;
  final isGoingToRegister = state.matchedLocation == AppConstants.registerRoute;

  // 1. Logic Onboarding (Highest priority)
  if (isFirstTime) {
    if (isGoingToOnboarding) return null;
    return AppConstants.onboardingRoute;
  }

  // 2. If the user is in Initial (/) and the load is complete:
  // - Logged in -> Home
  // - Not logged in -> Login
  if (isGoingToInitial) {
    return isLoggedIn ? AppConstants.gardenRoute : AppConstants.loginRoute;
  }

  // 3. If logged in:
  if (isLoggedIn) {
    // Block Login/Register/Onboarding access
    if (isGoingToLogin || isGoingToRegister || isGoingToOnboarding) {
      return AppConstants.gardenRoute;
    }
  }
  // 4. If not logged in:
  else {
    // Block access to Home and other routes other than Login/Register.
    if (!isGoingToLogin && !isGoingToRegister) {
      return AppConstants.loginRoute;
    }
  }

  return null;
}
