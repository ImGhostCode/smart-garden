// Plant Local Data Source
// Handles local storage for plant data

import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../models/plant_model.dart';

abstract class PlantLocalDataSource {
  /// Gets cached plants from local storage
  Future<List<PlantModel>> getCachedPlants();

  /// Caches plants to local storage
  Future<void> cachePlants(List<PlantModel> plants);
}

class PlantLocalDataSourceImpl implements PlantLocalDataSource {
  // Add local storage dependency here
  final LocalStorageService localStorageService;

  PlantLocalDataSourceImpl(this.localStorageService);

  @override
  Future<List<PlantModel>> getCachedPlants() async {
    final plantStrings = localStorageService.getStringList(
      AppConstants.plantsKey,
    );
    if (plantStrings == null) return [];

    return plantStrings
        .map((e) => PlantModel.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cachePlants(List<PlantModel> plants) async {
    final plantStrings = plants.map((e) => jsonEncode(e.toJson())).toList();
    await localStorageService.setStringList(
      AppConstants.plantsKey,
      plantStrings,
    );
  }
}
