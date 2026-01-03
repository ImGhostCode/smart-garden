// Garden Local Data Source
// Handles local storage for garden data

import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../models/garden_model.dart';

abstract class GardenLocalDataSource {
  /// Gets cached gardens from local storage
  Future<List<GardenModel>> getCachedGardens();

  /// Caches gardens to local storage
  Future<void> cacheGardens(List<GardenModel> gardens);
}

class GardenLocalDataSourceImpl implements GardenLocalDataSource {
  // Add local storage dependency here
  final LocalStorageService localStorageService;

  GardenLocalDataSourceImpl(this.localStorageService);

  @override
  Future<List<GardenModel>> getCachedGardens() async {
    final gardenStrings = localStorageService.getStringList(
      AppConstants.gardensKey,
    );
    if (gardenStrings == null) return [];

    return gardenStrings
        .map((e) => GardenModel.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheGardens(List<GardenModel> gardens) async {
    final gardenStrings = gardens.map((e) => jsonEncode(e.toJson())).toList();
    await localStorageService.setStringList(
      AppConstants.gardensKey,
      gardenStrings,
    );
  }
}
