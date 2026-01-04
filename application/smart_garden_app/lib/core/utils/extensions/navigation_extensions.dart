import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/plant/domain/entities/plant_entity.dart';
import '../../../features/water_routine/domain/entities/water_routine_entity.dart';
import '../../../features/water_schedule/domain/entities/water_schedule_entity.dart';
import '../../../features/weather_client/domain/entities/weather_client_entity.dart';
import '../../../features/zone/domain/entities/zone_entity.dart';
import '../../router/app_routers.dart';

extension NavigationContext on BuildContext {
  void goCreateGarden() {
    pushNamed(RouteNames.createGarden);
  }

  void goGardenDetail(String gardenId) {
    pushNamed(RouteNames.gardenDetail, pathParameters: {'gardenId': gardenId});
  }

  void goEditGarden(String gardenId) {
    pushNamed(RouteNames.editGarden, pathParameters: {'gardenId': gardenId});
  }

  void goZones(String gardenId) {
    pushNamed(RouteNames.zones, pathParameters: {'gardenId': gardenId});
  }

  void goAddZone(String gardenId) {
    pushNamed(RouteNames.addZone, pathParameters: {'gardenId': gardenId});
  }

  void goZoneDetail(String gardenId, String zoneId) {
    pushNamed(
      RouteNames.zoneDetail,
      pathParameters: {'gardenId': gardenId, 'zoneId': zoneId},
    );
  }

  void goEditZone(String gardenId, String zoneId, ZoneEntity zone) {
    pushNamed(
      RouteNames.editZone,
      pathParameters: {'gardenId': gardenId, 'zoneId': zoneId},
      extra: zone,
    );
  }

  void goPlants(String gardenId) {
    pushNamed(RouteNames.plants, pathParameters: {'gardenId': gardenId});
  }

  void goAddPlant(String gardenId) {
    pushNamed(RouteNames.addPlant, pathParameters: {'gardenId': gardenId});
  }

  void goPlantDetail(String gardenId, String plantId) {
    pushNamed(
      RouteNames.plantDetail,
      pathParameters: {'gardenId': gardenId, 'plantId': plantId},
    );
  }

  void goEditPlant(String gardenId, String plantId, PlantEntity plant) {
    pushNamed(
      RouteNames.editPlant,
      pathParameters: {'gardenId': gardenId, 'plantId': plantId},
      extra: plant,
    );
  }

  void goWaterSchedules() {
    pushNamed(RouteNames.waterSchedules);
  }

  void goNewWaterSchedule() {
    pushNamed(RouteNames.newWaterSchedule);
  }

  void goEditWaterSchedule(String scheduleId, WaterScheduleEntity ws) {
    pushNamed(
      RouteNames.editWaterSchedule,
      pathParameters: {'scheduleId': scheduleId},
      extra: ws,
    );
  }

  void goWeatherClients() {
    pushNamed(RouteNames.weatherClients);
  }

  void goNewWeatherClient() {
    pushNamed(RouteNames.newWeatherClient);
  }

  void goEditWeatherClient(String clientId, WeatherClientEntity wc) {
    pushNamed(
      RouteNames.editWeatherClient,
      pathParameters: {'clientId': clientId},
      extra: wc,
    );
  }

  void goWaterRoutines() {
    pushNamed(RouteNames.waterRoutines);
  }

  void goNewWaterRoutine() {
    pushNamed(RouteNames.newWaterRoutine);
  }

  void goEditWaterRoutine(String routineId, WaterRoutineEntity wr) {
    pushNamed(
      RouteNames.editWaterRoutine,
      pathParameters: {'routineId': routineId},
      extra: wr,
    );
  }

  void goBack() => pop();
  bool canGoBack() => canPop();

  void goToHome() => goNamed(RouteNames.garden);
  void goSettings() => pushNamed(RouteNames.settings);
}
