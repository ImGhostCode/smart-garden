// WaterSchedule Local Data Source
// Handles local storage for water_schedule data

import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../models/water_schedule_model.dart';

abstract class WaterScheduleLocalDataSource {
  /// Gets cached waterSchedules from local storage
  Future<List<WaterScheduleModel>> getCachedWaterSchedules();

  /// Caches waterSchedules to local storage
  Future<void> cacheWaterSchedules(List<WaterScheduleModel> waterSchedules);
}

class WaterScheduleLocalDataSourceImpl implements WaterScheduleLocalDataSource {
  // Add local storage dependency here
  final LocalStorageService localStorageService;

  WaterScheduleLocalDataSourceImpl(this.localStorageService);

  @override
  Future<List<WaterScheduleModel>> getCachedWaterSchedules() async {
    final waterScheduleStrings = localStorageService.getStringList(
      AppConstants.waterSchedulesKey,
    );
    if (waterScheduleStrings == null) return [];

    return waterScheduleStrings
        .map(
          (e) => WaterScheduleModel.fromJson(
            jsonDecode(e) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<void> cacheWaterSchedules(
    List<WaterScheduleModel> waterSchedules,
  ) async {
    final waterScheduleStrings = waterSchedules
        .map((e) => jsonEncode(e.toJson()))
        .toList();
    await localStorageService.setStringList(
      AppConstants.waterSchedulesKey,
      waterScheduleStrings,
    );
  }
}
