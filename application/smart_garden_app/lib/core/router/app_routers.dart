import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/garden/presentation/screens/edit_garden_screen.dart';
import '../../features/plant/domain/entities/plant_entity.dart';
import '../../features/plant/presentation/screens/add_plant_screen.dart';
import '../../features/plant/presentation/screens/edit_plant_screen.dart';
import '../../features/plant/presentation/screens/plant_detail_screen.dart';
import '../../features/plant/presentation/screens/plant_list_screen.dart';
import '../../features/water_routine/domain/entities/water_routine_entity.dart';
import '../../features/water_routine/presentation/screens/edit_water_routine_screen.dart';
import '../../features/water_routine/presentation/screens/new_water_routine_screen.dart';
import '../../features/water_schedule/domain/entities/water_schedule_entity.dart';
import '../../features/water_schedule/presentation/screens/edit_water_schedule_screen.dart';
import '../../features/water_schedule/presentation/screens/new_water_schedule_screen.dart';
import '../../features/weather_client/domain/entities/weather_client_entity.dart';
import '../../features/weather_client/presentation/screens/edit_weather_client_screen.dart';
import '../../features/weather_client/presentation/screens/new_weather_client_screen.dart';
import '../../features/zone/domain/entities/zone_entity.dart';
import '../../features/zone/presentation/screens/add_zone_screen.dart';
import '../../features/zone/presentation/screens/edit_zone_screen.dart';
import '../../features/zone/presentation/screens/zone_detail_screen.dart';
import '../../features/zone/presentation/screens/zone_list_screen.dart';
import '../constants/app_constants.dart';

class AppRoutes {
  static List<RouteBase> get authRoutes => [
    // Login route
    GoRoute(
      path: '/login',
      name: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),

    // Register route
    GoRoute(
      path: '/register',
      name: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),
  ];

  static List<RouteBase> get gardenSubRoutes => [
    GoRoute(
      path: 'edit',
      name: RouteNames.editGarden,
      builder: (context, state) =>
          EditGardenScreen(gardenId: state.pathParameters['gardenId']!),
    ),
    GoRoute(
      path: 'zone',
      name: RouteNames.zones,
      builder: (context, state) =>
          ZoneListScreen(gardenId: state.pathParameters['gardenId']!),
      routes: [
        GoRoute(
          path: 'add',
          name: RouteNames.addZone,
          builder: (context, state) =>
              AddZoneScreen(gardenId: state.pathParameters['gardenId']!),
        ),
        GoRoute(
          path: ':zoneId',
          name: RouteNames.zoneDetail,
          builder: (context, state) => ZoneDetailScreen(
            gardenId: state.pathParameters['gardenId']!,
            zoneId: state.pathParameters['zoneId']!,
          ),
          routes: [
            GoRoute(
              path: 'edit',
              name: RouteNames.editZone,
              builder: (context, state) => EditZoneScreen(
                gardenId: state.pathParameters['gardenId']!,
                zoneId: state.pathParameters['zoneId']!,
                zone: state.extra as ZoneEntity,
              ),
              redirect: (context, state) {
                final zone = state.extra;
                if (zone == null || zone is! ZoneEntity) {
                  return AppConstants.gardenRoute;
                }
                return null;
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: 'plant',
      name: RouteNames.plants,
      builder: (context, state) =>
          PlantListScreen(gardenId: state.pathParameters['gardenId']!),
      routes: [
        GoRoute(
          path: 'add',
          name: RouteNames.addPlant,
          builder: (context, state) =>
              AddPlantScreen(gardenId: state.pathParameters['gardenId']!),
        ),
        GoRoute(
          path: ':plantId',
          name: RouteNames.plantDetail,
          builder: (context, state) => PlantDetailScreen(
            gardenId: state.pathParameters['gardenId']!,
            plantId: state.pathParameters['plantId']!,
          ),
          routes: [
            GoRoute(
              path: 'edit',
              name: RouteNames.editPlant,
              builder: (context, state) => EditPlantScreen(
                plantId: state.pathParameters['plantId']!,
                plant: state.extra as PlantEntity,
              ),
              redirect: (context, state) {
                final plant = state.extra;
                if (plant == null || plant is! PlantEntity) {
                  return AppConstants.gardenRoute;
                }
                return null;
              },
            ),
          ],
        ),
      ],
    ),
  ];

  static List<RouteBase> get wsSubRoutes => [
    GoRoute(
      path: 'new',
      name: RouteNames.newWaterSchedule,
      builder: (context, state) => const NewWaterScheduleScreen(),
    ),
    GoRoute(
      path: ':scheduleId/edit',
      name: RouteNames.editWaterSchedule,
      builder: (context, state) => EditWaterScheduleScreen(
        ws: state.extra as WaterScheduleEntity,
        scheduleId: state.pathParameters['scheduleId']!,
      ),
      redirect: (context, state) {
        final ws = state.extra;
        if (ws == null || ws is! WaterScheduleEntity) {
          return AppConstants.gardenRoute;
        }
        return null;
      },
    ),
  ];
  static List<RouteBase> get wcSubRoutes => [
    GoRoute(
      path: 'new',
      name: RouteNames.newWeatherClient,
      builder: (context, state) => const NewWeatherClientScreen(),
    ),
    GoRoute(
      path: ':clientId/edit',
      name: RouteNames.editWeatherClient,
      builder: (context, state) => EditWeatherClientScreen(
        wc: state.extra as WeatherClientEntity,
        clientId: state.pathParameters['clientId']!,
      ),
      redirect: (context, state) {
        final wc = state.extra;
        if (wc == null || wc is! WeatherClientEntity) {
          return AppConstants.gardenRoute;
        }
        return null;
      },
    ),
  ];
  static List<RouteBase> get wrSubRoutes => [
    GoRoute(
      path: 'new',
      name: RouteNames.newWaterRoutine,
      builder: (context, state) => const NewWaterRoutineScreen(),
    ),
    GoRoute(
      path: ':routineId/edit',
      name: RouteNames.editWaterRoutine,
      builder: (context, state) => EditWaterRoutineScreen(
        waterRoutineId: state.pathParameters['routineId']!,
        waterRoutine: state.extra as WaterRoutineEntity,
      ),
      redirect: (context, state) {
        final wr = state.extra;
        if (wr == null || wr is! WaterRoutineEntity) {
          return AppConstants.gardenRoute;
        }
        return null;
      },
    ),
  ];
}

class RouteNames {
  static const String onboarding = 'onboarding';

  static const String login = 'login';
  static const String register = 'register';

  static const String home = 'home';
  static const String settings = 'settings';

  static const String garden = 'garden';
  static const String gardenDetail = 'gardenDetail';
  static const String createGarden = 'createGarden';
  static const String editGarden = 'editGarden';

  static const String zones = 'zones';
  static const String zoneDetail = 'zoneDetail';
  static const String addZone = 'addZone';
  static const String editZone = 'editZone';

  static const String plants = 'plants';
  static const String plantDetail = 'plantDetail';
  static const String addPlant = 'addPlant';
  static const String editPlant = 'editPlant';

  static const String waterSchedules = 'waterSchedules';
  static const String newWaterSchedule = 'newWaterSchedule';
  static const String editWaterSchedule = 'editWaterSchedule';

  static const String weatherClients = 'weatherClients';
  static const String newWeatherClient = 'newWeatherClient';
  static const String editWeatherClient = 'editWeatherClient';

  static const String waterRoutines = 'waterRoutines';
  static const String newWaterRoutine = 'newWaterRoutine';
  static const String editWaterRoutine = 'editWaterRoutine';
}
