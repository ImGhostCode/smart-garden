// WeatherClient Remote Data Source
// Handles API calls for weather_client data

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../zone/data/models/zone_model.dart';
import '../../domain/usecases/get_all_weather_clients.dart';
import '../../domain/usecases/get_weather_client_by_id.dart';
import '../models/weather_client_model.dart';

abstract class WeatherClientRemoteDataSource {
  /// Gets all weatherClients from the API
  Future<ApiResponse<List<WeatherClientModel>>> getAllWeatherClients(
    GetAllWeatherClientsParams params,
  );

  /// Gets a specific weatherClient by ID from the API
  Future<ApiResponse<WeatherClientModel>> getWeatherClientById(
    GetWeatherClientParams params,
  );

  Future<ApiResponse<WeatherDataModel>> getWeatherData(String weatherClientId);

  Future<ApiResponse<WeatherClientModel>> newWeatherClient(
    WeatherClientModel weatherClient,
  );

  Future<ApiResponse<WeatherClientModel>> editWeatherClient(
    WeatherClientModel weatherClient,
  );

  Future<ApiResponse<String>> deleteWeatherClient(String id);
}

class WeatherClientRemoteDataSourceImpl
    implements WeatherClientRemoteDataSource {
  final ApiClient _apiClient;

  WeatherClientRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ApiResponse<List<WeatherClientModel>>> getAllWeatherClients(
    GetAllWeatherClientsParams params,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.get(
        '/weather_clients',
        queryParameters: {'end_dated': params.endDated},
      );

      return ApiResponse<List<WeatherClientModel>>.fromJson(response, (data) {
        return (data as List)
            .map((e) => WeatherClientModel.fromJson(e))
            .toList();
      });
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<WeatherClientModel>> getWeatherClientById(
    GetWeatherClientParams params,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.get('/weather_clients/${params.id}');

      return ApiResponse<WeatherClientModel>.fromJson(
        response,
        (data) => WeatherClientModel.fromJson(data as Map<String, dynamic>),
      );
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  // Helper method to handle exceptions
  Exception _handleException(Exception e) {
    if (e is NetworkException ||
        e is ServerException ||
        e is UnauthorizedException ||
        e is BadRequestException) {
      return e;
    }
    return ServerException(message: e.toString());
  }

  @override
  Future<ApiResponse<WeatherDataModel>> getWeatherData(
    String weatherClientId,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.get(
        '/weather_clients/$weatherClientId/test',
      );

      return ApiResponse<WeatherDataModel>.fromJson(
        response,
        (data) => WeatherDataModel.fromJson(data as Map<String, dynamic>),
      );
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<WeatherClientModel>> newWeatherClient(
    WeatherClientModel weatherClient,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.post(
        '/weather_clients',
        data: {
          'name': weatherClient.name,
          'type': weatherClient.type,
          'options': weatherClient.options?.toJson(),
        },
      );

      return ApiResponse<WeatherClientModel>.fromJson(
        response,
        (data) => WeatherClientModel.fromJson(data as Map<String, dynamic>),
      );
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<WeatherClientModel>> editWeatherClient(
    WeatherClientModel weatherClient,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.patch(
        '/weather_clients/${weatherClient.id}',
        data: {
          'name': weatherClient.name,
          'type': weatherClient.type,
          'options': weatherClient.options?.toJson(),
        },
      );

      return ApiResponse<WeatherClientModel>.fromJson(
        response,
        (data) => WeatherClientModel.fromJson(data as Map<String, dynamic>),
      );
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<String>> deleteWeatherClient(String id) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.delete('/weather_clients/$id');

      return ApiResponse<String>.fromJson(response, (data) => data as String);
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }
}
