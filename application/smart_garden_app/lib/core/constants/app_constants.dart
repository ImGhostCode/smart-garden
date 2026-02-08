class AppConstants {
  // API constants
  static const String apiBaseUrl = 'http://api.yourdomain.com';

  // Storage constants
  static const String isFirstTimeKey = 'isFirstTime';
  static const String tokenKey = 'authToken';
  static const String userDataKey = 'userData';
  static const String refreshTokenKey = 'refreshToken';

  static const String gardensKey = 'gardens';
  static const String zonesKey = 'zones';
  static const String plantsKey = 'plants';
  static const String waterSchedulesKey = 'waterSchedules';
  static const String weatherClientsKey = 'weatherClients';
  static const String waterRoutinesKey = 'waterRoutines';
  static const String notificationClientsKey = 'notificationClients';

  // App constants
  static const String appName = 'Smart Garden';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.example.smart_garden';
  static const String iOSAppId = '123456789';
  static const String appcastUrl = 'https://your-appcast-url.com/appcast.xml';

  // Timeout durations
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Route constants
  static const String onboardingRoute = '/onboarding';
  static const String initialRoute = '/';

  static const String loginRoute = '/login';
  static const String registerRoute = '/register';

  static const String gardenRoute = '/garden';
  static const String waterScheduleRoute = '/water-schedule';
  static const String weatherClientRoute = '/weather-client';
  static const String notificationClientRoute = '/notification-client';
  static const String waterRoutineRoute = '/water-routine';
  static const String settingsRoute = '/settings';

  // Hive box names
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';
  static const String offlineSyncBox = 'offlineSync';

  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Accessibility
  static const Duration accessibilityTooltipDuration = Duration(seconds: 5);
  static const double accessibilityTouchTargetMinSize = 48.0;

  // App Review
  static const int minSessionsBeforeReview = 5;
  static const int minDaysBeforeReview = 7;
  static const int minActionsBeforeReview = 10;

  // UI
  static const double paddingSm = 8;
  static const double paddingMd = 12;
  static const double paddingLg = 16;

  static const double radiusSm = 3;
  static const double radiusMd = 5;
  static const double radiusLg = 14;

  static const double buttonSm = 45;
  static const double buttonMd = 50;
  static const double buttonLg = 55;

  static const double iconSm = 18;
  static const double iconMd = 24;
  static const double iconLg = 32;
}
