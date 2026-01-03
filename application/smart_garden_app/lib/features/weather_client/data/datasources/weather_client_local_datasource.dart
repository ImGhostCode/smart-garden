// WeatherClient Local Data Source
// Handles local storage for weather_client data

import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../domain/usecases/get_all_weather_clients.dart';
import '../models/weather_client_model.dart';

abstract class WeatherClientLocalDataSource {
  /// Gets cached weatherClients from local storage
  Future<List<WeatherClientModel>> getCachedWeatherClients(
    GetAllWeatherClientsParams params,
  );

  /// Caches weatherClients to local storage
  Future<void> cacheWeatherClients(List<WeatherClientModel> weatherClients);
}

class WeatherClientLocalDataSourceImpl implements WeatherClientLocalDataSource {
  // Add local storage dependency here
  final LocalStorageService localStorageService;

  WeatherClientLocalDataSourceImpl(this.localStorageService);

  @override
  Future<List<WeatherClientModel>> getCachedWeatherClients(
    GetAllWeatherClientsParams params,
  ) async {
    final weatherClientStrings = localStorageService.getStringList(
      AppConstants.weatherClientsKey,
    );
    if (weatherClientStrings == null) return [];

    return weatherClientStrings
        .map(
          (e) => WeatherClientModel.fromJson(
            jsonDecode(e) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<void> cacheWeatherClients(
    List<WeatherClientModel> weatherClients,
  ) async {
    final weatherClientStrings = weatherClients
        .map((e) => jsonEncode(e.toJson()))
        .toList();
    await localStorageService.setStringList(
      AppConstants.weatherClientsKey,
      weatherClientStrings,
    );
  }
}
