// WeatherClient Repository Interface
// Defines data operations for weather_client

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../zone/domain/entities/zone_entity.dart';
import '../entities/weather_client_entity.dart';
import '../usecases/get_all_weather_clients.dart';
import '../usecases/get_weather_client_by_id.dart';

abstract class WeatherClientRepository {
  /// Gets all weatherClient entities
  Future<Either<Failure, ApiResponse<List<WeatherClientEntity>>>>
  getAllWeatherClients(GetAllWeatherClientsParams params);

  /// Gets a specific weatherClient entity by ID
  Future<Either<Failure, ApiResponse<WeatherClientEntity>>>
  getWeatherClientById(GetWeatherClientParams params);

  Future<Either<Failure, ApiResponse<WeatherDataEntity>>> getWeatherData(
    String weatherClientId,
  );

  Future<Either<Failure, ApiResponse<WeatherClientEntity>>> newWeatherClient(
    WeatherClientEntity weatherClient,
  );

  Future<Either<Failure, ApiResponse<WeatherClientEntity>>> editWeatherClient(
    WeatherClientEntity weatherClient,
  );

  Future<Either<Failure, ApiResponse<String>>> deleteWeatherClient(String id);
}
