// WaterRoutine Local Data Source
// Handles local storage for water_routine data

import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../models/water_routine_model.dart';

abstract class WaterRoutineLocalDataSource {
  /// Gets cached waterRoutines from local storage
  Future<List<WaterRoutineModel>> getCachedWaterRoutines();

  /// Caches waterRoutines to local storage
  Future<void> cacheWaterRoutines(List<WaterRoutineModel> waterRoutines);
}

class WaterRoutineLocalDataSourceImpl implements WaterRoutineLocalDataSource {
  // Add local storage dependency here
  final LocalStorageService localStorageService;

  WaterRoutineLocalDataSourceImpl(this.localStorageService);

  @override
  Future<List<WaterRoutineModel>> getCachedWaterRoutines() async {
    final waterRoutineStrings = localStorageService.getStringList(
      AppConstants.waterRoutinesKey,
    );
    if (waterRoutineStrings == null) return [];
    return waterRoutineStrings
        .map(
          (e) =>
              WaterRoutineModel.fromJson(jsonDecode(e) as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> cacheWaterRoutines(List<WaterRoutineModel> waterRoutines) async {
    final waterRoutineStrings = waterRoutines
        .map((e) => jsonEncode(e.toJson()))
        .toList();
    await localStorageService.setStringList(
      AppConstants.waterRoutinesKey,
      waterRoutineStrings,
    );
  }
}
