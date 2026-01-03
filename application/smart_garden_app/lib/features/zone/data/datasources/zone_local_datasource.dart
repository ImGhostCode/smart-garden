// Zone Local Data Source
// Handles local storage for zone data

import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../models/zone_model.dart';

abstract class ZoneLocalDataSource {
  /// Gets cached zones from local storage
  Future<List<ZoneModel>> getCachedZones();

  /// Caches zones to local storage
  Future<void> cacheZones(List<ZoneModel> zones);
}

class ZoneLocalDataSourceImpl implements ZoneLocalDataSource {
  // Add local storage dependency here
  final LocalStorageService localStorageService;

  ZoneLocalDataSourceImpl(this.localStorageService);

  @override
  Future<List<ZoneModel>> getCachedZones() async {
    final zoneStrings = localStorageService.getStringList(
      AppConstants.zonesKey,
    );
    if (zoneStrings == null) return [];

    return zoneStrings
        .map((e) => ZoneModel.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheZones(List<ZoneModel> zones) async {
    final zoneStrings = zones.map((e) => jsonEncode(e.toJson())).toList();
    await localStorageService.setStringList(AppConstants.zonesKey, zoneStrings);
  }
}
