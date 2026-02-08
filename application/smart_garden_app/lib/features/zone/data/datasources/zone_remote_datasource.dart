// Zone Remote Data Source
// Handles API calls for zone data

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/usecases/delete_zone.dart';
import '../../domain/usecases/edit_zone.dart';
import '../../domain/usecases/get_all_zones.dart';
import '../../domain/usecases/get_water_history.dart';
import '../../domain/usecases/get_zone_by_id.dart';
import '../../domain/usecases/new_zone.dart';
import '../../domain/usecases/send_zone_action.dart';
import '../models/water_history_model.dart';
import '../models/zone_model.dart';

abstract class ZoneRemoteDataSource {
  /// Gets all zones from the API
  Future<ApiResponse<List<ZoneModel>>> getAllZones(GetAllZoneParams params);

  /// Gets a specific zone by ID from the API
  Future<ApiResponse<ZoneModel>> getZoneById(GetZoneParams params);

  Future<ApiResponse<List<WaterHistoryModel>>> getWaterHistory(
    GetWaterHistoryParams params,
  );

  Future<ApiResponse<ZoneModel>> addZone(NewZoneParams params);

  Future<ApiResponse<ZoneModel>> editZone(EditZoneParams params);

  Future<ApiResponse<String>> deleteZone(DeleteZoneParams params);

  Future<ApiResponse<void>> sendAction(ZoneActionParams params);
}

class ZoneRemoteDataSourceImpl implements ZoneRemoteDataSource {
  final ApiClient _apiClient;
  ZoneRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ApiResponse<List<ZoneModel>>> getAllZones(
    GetAllZoneParams params,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.get(
        '/gardens/${params.gardenId}/zones',
        queryParameters: {
          'end_dated': params.endDated,
          'exclude_weather_data': params.excludeWeather,
        },
      );

      return ApiResponse<List<ZoneModel>>.fromJson(response, (data) {
        return (data as List).map((e) => ZoneModel.fromJson(e)).toList();
      });
    } on Exception catch (e) {
      throw handleException(e);
    }
  }

  @override
  Future<ApiResponse<ZoneModel>> getZoneById(GetZoneParams params) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.get(
        '/gardens/${params.gardenId}/zones/${params.id}',
        queryParameters: {'exclude_weather_data': params.excludeWeather},
      );

      return ApiResponse<ZoneModel>.fromJson(response, (data) {
        return ZoneModel.fromJson(data as Map<String, dynamic>);
      });
    } on Exception catch (e) {
      throw handleException(e);
    }
  }

  // Helper method to handle exceptions
  Exception handleException(Exception e) {
    if (e is NetworkException ||
        e is ServerException ||
        e is UnauthorizedException ||
        e is BadRequestException) {
      return e;
    }
    return ServerException(message: e.toString());
  }

  @override
  Future<ApiResponse<List<WaterHistoryModel>>> getWaterHistory(
    GetWaterHistoryParams params,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.get(
        '/gardens/${params.gardenId}/zones/${params.zoneId}/history',
        queryParameters: {'range': params.range, 'limit': params.limit},
      );

      return ApiResponse<List<WaterHistoryModel>>.fromJson(response, (data) {
        return (data as List)
            .map((e) => WaterHistoryModel.fromJson(e))
            .toList();
      });
    } on Exception catch (e) {
      throw handleException(e);
    }
  }

  @override
  Future<ApiResponse<ZoneModel>> addZone(NewZoneParams params) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.post(
        '/gardens/${params.gardenId}/zones',
        data: {
          'name': params.zone.name,
          'details': {
            'description': params.zone.details!.description,
            if (params.zone.details!.notes != null)
              'notes': params.zone.details!.notes,
          },
          if (params.zone.skipCount != null)
            'skip_count': params.zone.skipCount,
          'position': params.zone.position,
          if (params.zone.waterSchedules != null &&
              params.zone.waterSchedules!.isNotEmpty)
            'water_schedule_ids': params.zone.waterSchedules!
                .map((e) => e.id)
                .toList(),
        },
      );

      return ApiResponse<ZoneModel>.fromJson(response, (data) {
        return ZoneModel.fromJson(data as Map<String, dynamic>);
      });
    } on Exception catch (e) {
      throw handleException(e);
    }
  }

  @override
  Future<ApiResponse<ZoneModel>> editZone(EditZoneParams params) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.patch(
        '/gardens/${params.gardenId}/zones/${params.id}',
        data: {
          'name': params.zone.name,
          'details': {
            'description': params.zone.details!.description,
            if (params.zone.details!.notes != null)
              'notes': params.zone.details!.notes,
          },
          if (params.zone.skipCount != null)
            'skip_count': params.zone.skipCount,
          'position': params.zone.position,
          if (params.zone.waterSchedules != null)
            'water_schedule_ids': params.zone.waterSchedules!
                .map((e) => e.id)
                .toList(),
        },
        queryParameters: {'exclude_weather_data': params.excludeWeather},
      );

      return ApiResponse<ZoneModel>.fromJson(response, (data) {
        return ZoneModel.fromJson(data as Map<String, dynamic>);
      });
    } on Exception catch (e) {
      throw handleException(e);
    }
  }

  @override
  Future<ApiResponse<String>> deleteZone(DeleteZoneParams params) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.delete(
        '/gardens/${params.gardenId}/zones/${params.id}',
      );

      return ApiResponse<String>.fromJson(response, (data) {
        return data as String;
      });
    } on Exception catch (e) {
      throw handleException(e);
    }
  }

  @override
  Future<ApiResponse<void>> sendAction(ZoneActionParams params) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.post(
        '/gardens/${params.gardenId}/zones/${params.zoneId}/action',
        data: {
          'water': {'duration_ms': params.water?.durationMs},
        },
      );

      return ApiResponse<void>.fromJson(response, (data) {
        return;
      });
    } on Exception catch (e) {
      throw handleException(e);
    }
  }
}
