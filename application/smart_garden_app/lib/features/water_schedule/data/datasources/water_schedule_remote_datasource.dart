// WaterSchedule Remote Data Source
// Handles API calls for water_schedule data

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/usecases/get_all_water_schedules.dart';
import '../../domain/usecases/get_water_schedule_by_id.dart';
import '../models/water_schedule_model.dart';

abstract class WaterScheduleRemoteDataSource {
  /// Gets all waterSchedules from the API
  Future<ApiResponse<List<WaterScheduleModel>>> getAllWaterSchedules(
    GetAllWSParams params,
  );

  /// Gets a specific waterSchedule by ID from the API
  Future<ApiResponse<WaterScheduleModel>> getWaterScheduleById(
    GetWSParams params,
  );

  Future<ApiResponse<WaterScheduleModel>> newWaterSchedule(
    WaterScheduleModel waterSchedule,
  );

  Future<ApiResponse<WaterScheduleModel>> editWaterSchedule(
    WaterScheduleModel waterSchedule,
  );

  Future<ApiResponse<String>> deleteWaterSchedule(String id);
}

class WaterScheduleRemoteDataSourceImpl
    implements WaterScheduleRemoteDataSource {
  // Add HTTP client dependency here

  @override
  Future<ApiResponse<List<WaterScheduleModel>>> getAllWaterSchedules(
    GetAllWSParams params,
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
        "message": "Water schedules retrieved successfully",
        "data": [
          {
            "id": "68de80dc1a38491918156281",
            "name": "Shrubs",
            "description": "Water shrubs every 5 days",
            "duration_ms": 2600000,
            "interval": 24,
            "start_time": "22:00",
            "weather_control": {
              "rain_control": {
                "baseline_value": 3,
                "factor": 0.85,
                "range": 6,
                "client_id": "68e1f4b4681d52cf1e8b34b0",
              },
              "temperature_control": {
                "baseline_value": 25,
                "factor": 0.9,
                "range": 12,
                "client_id": "68e1f4b4681d52cf1e8b34b0",
              },
            },
            "active_period": {"start_month": "May", "end_month": "Dec"},
            "end_date": null,
            "createdAt": "2025-10-02T13:40:44.711Z",
            "updatedAt": "2025-11-29T11:35:32.151Z",
            "weather_data": {
              "rain": {"mm": 245, "scale_factor": 0.4},
              "temperature": {"celsius": 34.5, "scale_factor": 1.3},
            },
            "next_water": {
              "time": "2025-12-06T15:00:00.000Z",
              "duration_ms": 2600000,
              "water_schedule": {
                "id": "68de80dc1a38491918156281",
                "name": "Shrubs",
              },
              "message": "Next scheduled watering (cron)",
            },
          },
          {
            "id": "68de80dc1a38491918156281",
            "name": "Summer Trees",
            "description": "Water shrubs every 2 days",
            "duration_ms": 2600000,
            "interval": 24,
            "start_time": "03:00",
            "weather_control": {
              "rain_control": {
                "baseline_value": 3,
                "factor": 0.85,
                "range": 6,
                "client_id": "68e1f4b4681d52cf1e8b34b0",
              },
              "temperature_control": {
                "baseline_value": 25,
                "factor": 0.9,
                "range": 12,
                "client_id": "68e1f4b4681d52cf1e8b34b0",
              },
            },
            "active_period": {"start_month": "May", "end_month": "Dec"},
            "end_date": null,
            "createdAt": "2025-10-02T13:40:44.711Z",
            "updatedAt": "2025-11-29T11:35:32.151Z",
            "weather_data": {
              "rain": {"mm": 245, "scale_factor": 0.4},
              "temperature": {"celsius": 34.5, "scale_factor": 1.3},
            },
            "next_water": {
              "time": "2025-12-06T15:00:00.000Z",
              "duration_ms": 2600000,
              "water_schedule": {
                "id": "68de80dc1a38491918156281",
                "name": "Summer Trees",
              },
              "message": "Next scheduled watering (cron)",
            },
          },
        ],
      };

      return ApiResponse<List<WaterScheduleModel>>.fromJson(response, (data) {
        return (data as List)
            .map((e) => WaterScheduleModel.fromJson(e))
            .toList();
      });
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<WaterScheduleModel>> getWaterScheduleById(
    GetWSParams id,
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
        "message": "Water schedule retrieved successfully",
        "data": {
          "id": "68de80dc1a38491918156281",
          "name": "Shrubs",
          "description": "Water shrubs every 5 days",
          "duration_ms": 2600000,
          "interval": 24,
          "start_time": "22:00",
          "weather_control": {
            "rain_control": {
              "baseline_value": 3,
              "factor": 0.85,
              "range": 6,
              "client_id": "68e1f4b4681d52cf1e8b34b0",
            },
            "temperature_control": {
              "baseline_value": 25,
              "factor": 0.9,
              "range": 12,
              "client_id": "68e1f4b4681d52cf1e8b34b0",
            },
          },
          "active_period": {"start_month": "May", "end_month": "Dec"},
          "end_date": null,
          "createdAt": "2025-10-02T13:40:44.711Z",
          "updatedAt": "2025-11-29T11:35:32.151Z",
          "weather_data": {
            "rain": {"mm": 245, "scale_factor": 0.4},
            "temperature": {"celsius": 34.5, "scale_factor": 1.3},
          },
          "next_water": {
            "time": "2025-12-06T15:00:00.000Z",
            "duration_ms": 2600000,
            "water_schedule": {
              "id": "68de80dc1a38491918156281",
              "name": "Shrubs",
            },
            "message": "Next scheduled watering (cron)",
          },
        },
      };

      return ApiResponse<WaterScheduleModel>.fromJson(
        response,
        (data) => WaterScheduleModel.fromJson(data as Map<String, dynamic>),
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
  Future<ApiResponse<WaterScheduleModel>> newWaterSchedule(
    WaterScheduleModel waterSchedule,
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
        "code": 201,
        "message": "Water schedule created successfully",
        "data": waterSchedule.toJson(),
      };

      return ApiResponse<WaterScheduleModel>.fromJson(
        response,
        (data) => WaterScheduleModel.fromJson(data as Map<String, dynamic>),
      );
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<WaterScheduleModel>> editWaterSchedule(
    WaterScheduleModel waterSchedule,
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
        "message": "Water schedule updated successfully",
        "data": waterSchedule.toJson(),
      };

      return ApiResponse<WaterScheduleModel>.fromJson(
        response,
        (data) => WaterScheduleModel.fromJson(data as Map<String, dynamic>),
      );
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<String>> deleteWaterSchedule(String id) async {
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
        "message": "Water schedule deleted successfully",
        "data": id,
      };

      return ApiResponse<String>.fromJson(response, (data) => data as String);
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }
}
