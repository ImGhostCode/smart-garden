// WeatherClient Remote Data Source
// Handles API calls for weather_client data

import '../../../../core/error/exceptions.dart';
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

      await Future.delayed(const Duration(seconds: 1));
      // final response = await _apiClient.post('/auth/login', data: {
      //   'email': email,
      //   'password': password,
      // });

      final response = {
        "status": "success",
        "code": 200,
        "message": "Weather clients retrieved successfully",
        "data": [
          {
            "id": "6905288a431116ae2f99f21aa",
            "type": "netatmo",
            "name": "Hà Nội",
            "options": {
              "station_id": "70:ee:50:01:95:b8",
              "station_name": "Hà Nội",
              "rain_module_id": "05:00:00:01:d0:0e",
              "rain_module_type": "NAModule3",
              "outdoor_module_id": "02:00:00:01:7a:d4",
              "outdoor_module_type": "NAModule1",
              "authentication": {
                "refresh_token":
                    "68fa349a42eafc6c9501add9|19329013c628ce3b51a959488a84057f",
                "access_token":
                    "68fa349a42eafc6c9501add9|3487f41bbcdd47fbdbbcaaa71e02a6d9",
                "expiration_date": "2025-12-04T14:13:27.147Z",
              },
              "client_id": "68fa39fb5e81ee12d80c959b",
              "client_secret": "6gEdndsYCc5qHWXgISyU0ZhqfLzMDZD6E34n28OGW4D",
            },
            "end_date": null,
            "createdAt": "2025-11-01T04:12:20.465Z",
            "updatedAt": "2025-12-04T11:13:27.149Z",
          },
          {
            "id": "690583bc31116ae2f99f21ac",
            "name": "Fake WC",
            "type": "fake",
            "options": {
              "rain_mm": 2,
              "rain_interval_ms": 86400000,
              "avg_high_temperature": 80,
              "error": "",
            },
            "end_date": null,
            "createdAt": "2025-11-01T04:12:44.867Z",
            "updatedAt": "2025-11-08T04:35:00.229Z",
          },
          {
            "id": "690588bc31116ae2f99f21ac",
            "name": "Fake WC",
            "type": "fake",
            "options": {
              "rain_mm": 2,
              "rain_interval_ms": 86400000,
              "avg_high_temperature": 80,
              "error": "",
            },
            "end_date": null,
            "createdAt": "2025-11-01T04:12:44.867Z",
            "updatedAt": "2025-11-08T04:35:00.229Z",
          },
          {
            "id": "690588bc311163e2f99f21ac",
            "name": "Fake WC",
            "type": "fake",
            "options": {
              "rain_mm": 2,
              "rain_interval_ms": 86400000,
              "avg_high_temperature": 80,
              "error": "",
            },
            "end_date": null,
            "createdAt": "2025-11-01T04:12:44.867Z",
            "updatedAt": "2025-11-08T04:35:00.229Z",
          },
          {
            "id": "690688bc314116ae2f99f21ac",
            "name": "Fake WC",
            "type": "fake",
            "options": {
              "rain_mm": 2,
              "rain_interval_ms": 86400000,
              "avg_high_temperature": 80,
              "error": "",
            },
            "end_date": null,
            "createdAt": "2025-11-01T04:12:44.867Z",
            "updatedAt": "2025-11-08T04:35:00.229Z",
          },
        ],
      };

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

      await Future.delayed(const Duration(seconds: 2));
      // final response = await _apiClient.post('/auth/login', data: {
      //   'email': email,
      //   'password': password,
      // });

      final response = {
        "status": "success",
        "code": 200,
        "message": "Weather client retrieved successfully",
        "data": {
          "id": "690588a431116ae2f99f21aa",
          "type": "netatmo",
          "name": "Hà Nội",
          "options": {
            "station_id": "70:ee:50:01:95:b8",
            "station_name": "Hà Nội",
            "rain_module_id": "05:00:00:01:d0:0e",
            "rain_module_type": "NAModule3",
            "outdoor_module_id": "02:00:00:01:7a:d4",
            "outdoor_module_type": "NAModule1",
            "authentication": {
              "refresh_token":
                  "68fa349a42eafc6c9501add9|19329013c628ce3b51a959488a84057f",
              "access_token":
                  "68fa349a42eafc6c9501add9|3487f41bbcdd47fbdbbcaaa71e02a6d9",
              "expiration_date": "2025-12-04T14:13:27.147Z",
            },
            "client_id": "68fa39fb5e81ee12d80c959b",
            "client_secret": "6gEdndsYCc5qHWXgISyU0ZhqfLzMDZD6E34n28OGW4D",
          },
          "end_date": null,
          "createdAt": "2025-11-01T04:12:20.465Z",
          "updatedAt": "2025-12-04T11:13:27.149Z",
        },
      };

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

      await Future.delayed(const Duration(seconds: 2));

      final response = {
        "status": "success",
        "code": 200,
        "message": "Weather data retrieved successfully",
        "data": {
          "rain": {"mm": 150},
          "temperature": {"celsius": 22.5},
        },
      };

      // final response = {
      //   "status": 'error',
      //   "code": 500,
      //   "message": 'Failed to fetch weather data',
      // };

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

      await Future.delayed(const Duration(seconds: 2));
      // final response = await _apiClient.post('/auth/login', data: {
      //   'email': email,
      //   'password': password,
      // });

      final response = {
        "status": "success",
        "code": 200,
        "message": "Weather client created successfully",
        "data": weatherClient.toJson(),
      };

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

      await Future.delayed(const Duration(seconds: 2));
      // final response = await _apiClient.post('/auth/login', data: {
      //   'email': email,
      //   'password': password,
      // });

      final response = {
        "status": "success",
        "code": 200,
        "message": "Weather client updated successfully",
        "data": weatherClient.toJson(),
      };

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

      await Future.delayed(const Duration(seconds: 2));
      // final response = await _apiClient.post('/auth/login', data: {
      //   'email': email,
      //   'password': password,
      // });

      final response = {
        "status": "success",
        "code": 200,
        "message": "Weather client deleted successfully",
        "data": id,
      };

      return ApiResponse<String>.fromJson(response, (data) => data as String);
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }
}
