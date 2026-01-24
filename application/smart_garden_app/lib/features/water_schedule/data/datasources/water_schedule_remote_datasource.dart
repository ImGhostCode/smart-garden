// WaterSchedule Remote Data Source
// Handles API calls for water_schedule data

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
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
  final ApiClient _apiClient;

  WaterScheduleRemoteDataSourceImpl(this._apiClient);

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

      final response = await _apiClient.get(
        '/water_schedules',
        queryParameters: {
          'end_dated': params.endDated,
          'exclude_weather_data': params.excludeWeatherData,
        },
      );

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
    GetWSParams params,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.get(
        '/water_schedules/${params.id}',
        queryParameters: {'exclude_weather_data': params.excludeWeatherData},
      );

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

      final response = await _apiClient.post(
        '/water_schedules',
        data: {
          'name': waterSchedule.name,
          'description': waterSchedule.description,
          'duration_ms': waterSchedule.durationMs,
          'interval': waterSchedule.interval,
          'start_time': waterSchedule.startTime,
          if (waterSchedule.activePeriod != null)
            'active_period': {
              'start_month': waterSchedule.activePeriod!.startMonth!.substring(
                0,
                3,
              ),
              'end_month': waterSchedule.activePeriod!.endMonth!.substring(
                0,
                3,
              ),
            },
        },
        queryParameters: {'exclude_weather_data': true},
      );

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

      final response = await _apiClient.patch(
        '/water_schedules/${waterSchedule.id}',
        data: {
          'name': waterSchedule.name,
          'description': waterSchedule.description,
          'duration_ms': waterSchedule.durationMs,
          'interval': waterSchedule.interval,
          'start_time': waterSchedule.startTime,
          if (waterSchedule.activePeriod != null)
            'active_period': {
              'start_month': waterSchedule.activePeriod!.startMonth!.substring(
                0,
                3,
              ),
              'end_month': waterSchedule.activePeriod!.endMonth!.substring(
                0,
                3,
              ),
            },
        },
        queryParameters: {'exclude_weather_data': true},
      );

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

      final response = await _apiClient.delete(
        '/water_schedules/$id',
        queryParameters: {'exclude_weather_data': true},
      );

      return ApiResponse<String>.fromJson(response, (data) => data as String);
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }
}
