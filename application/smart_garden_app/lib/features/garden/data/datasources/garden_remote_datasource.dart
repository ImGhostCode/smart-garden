// Garden Remote Data Source
// Handles API calls for garden data

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/usecases/get_all_gardens.dart';
import '../../domain/usecases/send_garden_action.dart';
import '../models/garden_model.dart';

abstract class GardenRemoteDataSource {
  /// Gets all gardens from the API
  Future<ApiResponse<List<GardenModel>>> getAllGardens(
    GetAllGardenParams params,
  );

  /// Gets a specific garden by ID from the API
  Future<ApiResponse<GardenModel>> getGardenById(String id);

  Future<ApiResponse<GardenModel>> createGarden(GardenModel garden);

  Future<ApiResponse<GardenModel>> editGarden(GardenModel garden);

  Future<ApiResponse<String>> deleteGarden(String id);

  Future<ApiResponse<void>> sendAction(GardenActionParams params);
}

class GardenRemoteDataSourceImpl implements GardenRemoteDataSource {
  final ApiClient _apiClient;

  GardenRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ApiResponse<List<GardenModel>>> getAllGardens(
    GetAllGardenParams params,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.get(
        '/gardens',
        queryParameters: {'end_dated': params.endDated},
      );

      return ApiResponse<List<GardenModel>>.fromJson(
        response,
        (data) =>
            (data as List).map((item) => GardenModel.fromJson(item)).toList(),
      );
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<GardenModel>> getGardenById(String id) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.get('/gardens/$id');

      return ApiResponse<GardenModel>.fromJson(
        response,
        (data) => GardenModel.fromJson(data as Map<String, dynamic>),
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
  Future<ApiResponse<GardenModel>> createGarden(GardenModel garden) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }
      final response = await _apiClient.post(
        '/gardens',
        data: {
          'name': garden.name,
          'topic_prefix': garden.topicPrefix,
          'max_zones': garden.maxZones,
          if (garden.lightSchedule != null)
            'light_schedule': {
              'duration_ms': garden.lightSchedule!.durationMs,
              'start_time': garden.lightSchedule!.startTime,
            },
          if (garden.notificationClient != null)
            'notification_client_id': garden.notificationClient!.id,
          if (garden.notificationSettings != null)
            'notification_settings': {
              'controller_startup':
                  garden.notificationSettings!.controllerStartup,
              'light_schedule': garden.notificationSettings!.lightSchedule,
              'watering_started': garden.notificationSettings!.wateringStarted,
              'watering_completed':
                  garden.notificationSettings!.wateringCompleted,
              if (garden.notificationSettings!.downtimeMs != null)
                'downtime_ms': garden.notificationSettings!.downtimeMs,
            },
        },
      );

      return ApiResponse<GardenModel>.fromJson(
        response,
        (data) => GardenModel.fromJson(data as Map<String, dynamic>),
      );
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<GardenModel>> editGarden(GardenModel garden) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.patch(
        '/gardens/${garden.id}',
        data: {
          'name': garden.name,
          'topic_prefix': garden.topicPrefix,
          'max_zones': garden.maxZones,
          if (garden.lightSchedule != null)
            'light_schedule': {
              'duration_ms': garden.lightSchedule!.durationMs,
              'start_time': garden.lightSchedule!.startTime,
            },
          if (garden.controllerConfig != null)
            'controller_config': {
              if (garden.controllerConfig!.valvePins != null &&
                  garden.controllerConfig!.valvePins!.isNotEmpty)
                'valve_pins': garden.controllerConfig!.valvePins,
              if (garden.controllerConfig!.pumpPins != null &&
                  garden.controllerConfig!.pumpPins!.isNotEmpty)
                'pump_pins': garden.controllerConfig!.pumpPins,
              if (garden.controllerConfig!.lightPin != null)
                'light_pin': garden.controllerConfig!.lightPin!,
              if (garden.controllerConfig!.tempHumidityPin != null)
                'temp_humidity_pin': garden.controllerConfig!.tempHumidityPin!,
              if (garden.controllerConfig!.tempHumidityPin != null)
                'temp_hum_interval_ms':
                    garden.controllerConfig!.tempHumIntervalMs,
            },
          if (garden.notificationClient != null)
            'notification_client_id': garden.notificationClient!.id,
          if (garden.notificationSettings != null)
            'notification_settings': {
              'controller_startup':
                  garden.notificationSettings!.controllerStartup,
              'light_schedule': garden.notificationSettings!.lightSchedule,
              'watering_started': garden.notificationSettings!.wateringStarted,
              'watering_completed':
                  garden.notificationSettings!.wateringCompleted,
              if (garden.notificationSettings!.downtimeMs != null)
                'downtime_ms': garden.notificationSettings!.downtimeMs,
            },
        },
      );

      return ApiResponse<GardenModel>.fromJson(
        response,
        (data) => GardenModel.fromJson(data as Map<String, dynamic>),
      );
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<String>> deleteGarden(String id) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.delete('/gardens/$id');

      return ApiResponse<String>.fromJson(response, (data) => data as String);
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<void>> sendAction(GardenActionParams params) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.post(
        '/gardens/${params.gardenId}/action',
        data: {
          if (params.light != null)
            'light': {
              'state': params.light!.state,
              if (params.light!.forDuration != null)
                'for_duration_ms': params.light!.forDuration,
            },
          if (params.stop != null) 'stop': {'all': params.stop!.all},
          if (params.update != null)
            'update': {'config': params.update!.config},
        },
      );
      return ApiResponse<void>.fromJson(response, (data) {});
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }
}
