import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/app_skeleton.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/water_routine/presentation/screens/water_routine_screen.dart';
import '../../features/water_schedule/presentation/screens/water_schedule_screen.dart';
import '../../features/weather_client/presentation/screens/weather_client_screen.dart';
import '../constants/app_constants.dart';

final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final isFirstTime = ref.watch(onboardingProvider);
  // Watch for locale changes - this rebuilds the router when locale changes
  // ref.watch(persistentLocaleProvider);

  // // Create a router with locale awareness
  return GoRouter(
    initialLocation: AppConstants.initialRoute,
    debugLogDiagnostics: true,
    // Add the observer for locale awareness
    // observers: [ref.read(localizationRouterObserverProvider)],
    redirect: (context, state) {
      // Nếu đang check login status thì không redirect, giữ nguyên ở '/'
      if (authState.isCheckingStatus) {
        return null;
      }

      // --- Các biến trạng thái và route đang truy cập ---
      final isLoggedIn = authState.isAuthenticated;
      final isGoingToInitial =
          state.matchedLocation == AppConstants.initialRoute; // Thêm check này
      final isGoingToOnboarding =
          state.matchedLocation == AppConstants.onboardingRoute;
      final isGoingToLogin = state.matchedLocation == AppConstants.loginRoute;
      final isGoingToRegister =
          state.matchedLocation == AppConstants.registerRoute;

      // 1. Logic Onboarding (Ưu tiên cao nhất)
      if (isFirstTime) {
        if (isGoingToOnboarding) return null;
        return AppConstants.onboardingRoute;
      }

      // 2. Nếu user đang ở Initial (/) và đã load xong:
      // - Đã login -> Home
      // - Chưa login -> Login
      if (isGoingToInitial) {
        return isLoggedIn ? AppConstants.homeRoute : AppConstants.loginRoute;
      }

      // 3. Nếu đã đăng nhập:
      if (isLoggedIn) {
        // Chặn truy cập Login/Register/Onboarding
        if (isGoingToLogin || isGoingToRegister || isGoingToOnboarding) {
          return AppConstants.homeRoute;
        }
      }
      // 4. Nếu chưa đăng nhập:
      else {
        // Chặn truy cập Home và các route khác không phải Login/Register
        if (!isGoingToLogin && !isGoingToRegister) {
          return AppConstants.loginRoute;
        }
      }

      return null;
    },
    routes: [
      // Home route
      GoRoute(
        path: AppConstants.onboardingRoute,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Login route
      GoRoute(
        path: AppConstants.loginRoute,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Register route
      GoRoute(
        path: AppConstants.registerRoute,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppConstants.settingsRoute,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      // Splash route
      GoRoute(
        path: AppConstants.initialRoute,
        builder: (context, state) {
          // Nếu đang load thì hiện Splash
          if (authState.isCheckingStatus) {
            return const SplashScreen();
          }
          // Nếu load xong thì logic redirect ở trên sẽ tự chuyển trang
          return const SizedBox();
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return AppSkeleton(child: child); // The persistent layout
        },
        routes: <RouteBase>[
          GoRoute(
            path: AppConstants.homeRoute,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const HomeScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurveTween(
                          curve: Curves.easeInOutCirc,
                        ).animate(animation),
                        child: child,
                      );
                    },
              );
            },
            routes: const [
              // GoRoute(
              //   path: AppConstants.child,
              //   name: RouteNames.child,
              //   builder: (context, state) => const PatientInfoScreen(),
              // ),
            ],
          ),
          GoRoute(
            path: AppConstants.waterScheduleRoute,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const WaterScheduleScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurveTween(
                          curve: Curves.easeInOutCirc,
                        ).animate(animation),
                        child: child,
                      );
                    },
              );
            },
          ),
          GoRoute(
            path: AppConstants.weatherClientRoute,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const WeatherClientScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurveTween(
                          curve: Curves.easeInOutCirc,
                        ).animate(animation),
                        child: child,
                      );
                    },
              );
            },
          ),
          GoRoute(
            path: AppConstants.waterRoutineRoute,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const WaterRoutineScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurveTween(
                          curve: Curves.easeInOutCirc,
                        ).animate(animation),
                        child: child,
                      );
                    },
              );
            },
          ),
        ],
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
              onPressed: () => context.go(AppConstants.homeRoute),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
