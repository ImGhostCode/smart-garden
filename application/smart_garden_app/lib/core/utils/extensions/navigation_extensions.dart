import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  void goEditZone(String gardenId, String zoneId) {
    pushNamed(
      RouteNames.editZone,
      pathParameters: {'gardenId': gardenId, 'zoneId': zoneId},
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

  void goEditPlant(String gardenId, String plantId) {
    pushNamed(
      RouteNames.editPlant,
      pathParameters: {'gardenId': gardenId, 'plantId': plantId},
    );
  }

  void goWaterSchedules() {
    pushNamed(RouteNames.waterSchedules);
  }

  void goNewWaterSchedule() {
    pushNamed(RouteNames.newWaterSchedule);
  }

  void goEditWaterSchedule(String scheduleId) {
    pushNamed(
      RouteNames.editWaterSchedule,
      pathParameters: {'scheduleId': scheduleId},
    );
  }

  void goWeatherClients() {
    pushNamed(RouteNames.weatherClients);
  }

  void goNewWeatherClient() {
    pushNamed(RouteNames.newWeatherClient);
  }

  void goEditWeatherClient(String clientId) {
    pushNamed(
      RouteNames.editWeatherClient,
      pathParameters: {'clientId': clientId},
    );
  }

  void goWaterRoutines() {
    pushNamed(RouteNames.waterRoutines);
  }

  void goNewWaterRoutine() {
    pushNamed(RouteNames.newWaterRoutine);
  }

  void goEditWaterRoutine(String routineId) {
    pushNamed(
      RouteNames.editWaterRoutine,
      pathParameters: {'routineId': routineId},
    );
  }

  void goBack() => pop();
  bool canGoBack() => canPop();

  void goToHome() => goNamed(RouteNames.garden);
  void goSettings() => pushNamed(RouteNames.settings);
}
