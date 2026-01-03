// WaterRoutine Remote Data Source
// Handles API calls for water_routine data

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/usecases/get_all_water_routines.dart';
import '../models/water_routine_model.dart';

abstract class WaterRoutineRemoteDataSource {
  /// Gets all waterRoutines from the API
  Future<List<WaterRoutineModel>> getAllWaterRoutines(GetAllWRParams params);

  /// Gets a specific waterRoutine by ID from the API
  Future<WaterRoutineModel> getWaterRoutineById(String id);

  Future<WaterRoutineModel> newWaterRoutine(WaterRoutineModel waterRoutine);

  Future<WaterRoutineModel> editWaterRoutine(WaterRoutineModel waterRoutine);
}

class WaterRoutineRemoteDataSourceImpl implements WaterRoutineRemoteDataSource {
  // Add HTTP client dependency here

  @override
  Future<List<WaterRoutineModel>> getAllWaterRoutines(
    GetAllWRParams params,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      await Future.delayed(const Duration(seconds: 3));
      // final response = await _apiClient.post('/auth/login', data: {
      //   'email': email,
      //   'password': password,
      // });

      final response = [
        {
          "id": "691f1b2385d5734d35cd7669",
          "name": "Morning Routine",
          "steps": [
            {
              "zone": {"id": "68de8783b68657a7ab28132e", "name": "Flowers"},
              "duration_ms": 60000,
            },
            {
              "zone": {"id": "68de8783b38657a4ab28132e", "name": "Bushes"},
              "duration_ms": 1080000,
            },
          ],
          "end_date": null,
          "createdAt": "2025-11-20T13:44:03.011Z",
          "updatedAt": "2025-11-21T04:02:00.058Z",
        },
        {
          "id": "6920c3d485d5734d35cd7670",
          "name": "Evening Routine",
          "steps": [
            {
              "zone": {"id": "68de8783b68657a7ab28132e", "name": "Flowers"},
              "duration_ms": 60000,
            },
            {
              "zone": {"id": "68de8783b38657a4ab28132e", "name": "Bushes"},
              "duration_ms": 1080000,
            },
          ],
          "end_date": null,
          "createdAt": "2025-11-20T15:30:45.123Z",
          "updatedAt": "2025-11-21T05:10:15.456Z",
        },
      ];

      return response.map((e) => WaterRoutineModel.fromJson(e)).toList();
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<WaterRoutineModel> getWaterRoutineById(String id) async {
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
        "id": "691f1b2385d5734d35cd7669",
        "name": "Morning Routine",
        "steps": [
          {
            "zone": {"id": "68de862ab78657a4ab281c2a", "name": "Front Garden"},
            "duration_ms": 80000,
          },
          {
            "zone": {"id": "68de8996b78657a4ab281c37", "name": "Backyard"},
            "duration_ms": 1080000,
          },
        ],
        "end_date": null,
        "createdAt": "2025-11-20T13:44:03.011Z",
        "updatedAt": "2025-11-21T04:02:00.058Z",
      };

      return WaterRoutineModel.fromJson(response);
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
  Future<WaterRoutineModel> editWaterRoutine(
    WaterRoutineModel waterRoutine,
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

      return WaterRoutineModel.fromJson(waterRoutine.toJson());
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<WaterRoutineModel> newWaterRoutine(
    WaterRoutineModel waterRoutine,
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

      return WaterRoutineModel.fromJson(waterRoutine.toJson());
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }
}
