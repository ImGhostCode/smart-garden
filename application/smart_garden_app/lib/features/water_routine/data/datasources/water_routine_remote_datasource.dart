// WaterRoutine Remote Data Source
// Handles API calls for water_routine data

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/usecases/get_all_water_routines.dart';
import '../models/water_routine_model.dart';

abstract class WaterRoutineRemoteDataSource {
  /// Gets all waterRoutines from the API
  Future<ApiResponse<List<WaterRoutineModel>>> getAllWaterRoutines(
    GetAllWRParams params,
  );

  /// Gets a specific waterRoutine by ID from the API
  Future<ApiResponse<WaterRoutineModel>> getWaterRoutineById(String id);

  Future<ApiResponse<WaterRoutineModel>> newWaterRoutine(
    WaterRoutineModel waterRoutine,
  );

  Future<ApiResponse<WaterRoutineModel>> editWaterRoutine(
    WaterRoutineModel waterRoutine,
  );

  Future<ApiResponse<String>> deleteWaterRoutine(String id);

  Future<ApiResponse<void>> runWaterRoutine(String id);
}

class WaterRoutineRemoteDataSourceImpl implements WaterRoutineRemoteDataSource {
  final ApiClient _apiClient;

  WaterRoutineRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ApiResponse<List<WaterRoutineModel>>> getAllWaterRoutines(
    GetAllWRParams params,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.get(
        '/water_routines',
        queryParameters: {'end_dated': params.endDated},
      );

      return ApiResponse<List<WaterRoutineModel>>.fromJson(response, (data) {
        return (data as List)
            .map((e) => WaterRoutineModel.fromJson(e))
            .toList();
      });
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<WaterRoutineModel>> getWaterRoutineById(String id) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.get('/water_routines/$id');

      return ApiResponse<WaterRoutineModel>.fromJson(
        response,
        (data) => WaterRoutineModel.fromJson(data as Map<String, dynamic>),
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
  Future<ApiResponse<WaterRoutineModel>> editWaterRoutine(
    WaterRoutineModel waterRoutine,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.patch(
        '/water_routines/${waterRoutine.id}',
        data: {
          'name': waterRoutine.name,
          'steps': waterRoutine.steps!
              .map(
                (step) => {
                  'zone_id': step.zone?.id,
                  'duration_ms': step.durationMs,
                },
              )
              .toList(),
        },
      );

      return ApiResponse<WaterRoutineModel>.fromJson(
        response,
        (data) => WaterRoutineModel.fromJson(data as Map<String, dynamic>),
      );
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<WaterRoutineModel>> newWaterRoutine(
    WaterRoutineModel waterRoutine,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.post(
        '/water_routines',
        data: {
          'name': waterRoutine.name,
          'steps': waterRoutine.steps!
              .map(
                (step) => {
                  'zone_id': step.zone?.id,
                  'duration_ms': step.durationMs,
                },
              )
              .toList(),
        },
      );

      return ApiResponse<WaterRoutineModel>.fromJson(
        response,
        (data) => WaterRoutineModel.fromJson(data as Map<String, dynamic>),
      );
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<String>> deleteWaterRoutine(String id) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.delete('/water_routines/$id');

      return ApiResponse<String>.fromJson(response, (data) => data as String);
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<void>> runWaterRoutine(String id) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.post('/water_routines/$id/run');

      return ApiResponse<void>.fromJson(response, (data) {});
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }
}
