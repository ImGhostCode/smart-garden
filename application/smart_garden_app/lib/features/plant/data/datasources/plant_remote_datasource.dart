// Plant Remote Data Source
// Handles API calls for plant data

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/usecases/add_plant.dart';
import '../../domain/usecases/delete_plant.dart';
import '../../domain/usecases/edit_plant.dart';
import '../../domain/usecases/get_all_plants.dart';
import '../../domain/usecases/get_plant_by_id.dart';
import '../models/plant_model.dart';

abstract class PlantRemoteDataSource {
  /// Gets all plants from the API
  Future<ApiResponse<List<PlantModel>>> getAllPlants(GetAllPlantParams params);

  /// Gets a specific plant by ID from the API
  Future<ApiResponse<PlantModel>> getPlantById(GetPlantParams params);

  Future<ApiResponse<PlantModel>> editPlant(EditPlantParams params);

  Future<ApiResponse<PlantModel>> addPlant(AddPlantParams params);

  Future<ApiResponse<String>> deletePlant(DeletePlantParams params);
}

class PlantRemoteDataSourceImpl implements PlantRemoteDataSource {
  final ApiClient _apiClient;

  PlantRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ApiResponse<List<PlantModel>>> getAllPlants(
    GetAllPlantParams params,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.get(
        '/gardens/${params.gardenId}/plants',
        queryParameters: {'end_dated': params.endDated},
      );

      return ApiResponse<List<PlantModel>>.fromJson(
        response,
        (data) =>
            (data as List).map((item) => PlantModel.fromJson(item)).toList(),
      );
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<PlantModel>> getPlantById(GetPlantParams params) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.get(
        '/gardens/${params.gardenId}/plants/${params.plantId}',
      );

      return ApiResponse<PlantModel>.fromJson(
        response,
        (data) => PlantModel.fromJson(data as Map<String, dynamic>),
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
  Future<ApiResponse<PlantModel>> addPlant(AddPlantParams params) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.post(
        '/gardens/${params.gardenId}/plants',
        data: {
          "name": params.plant.name,
          "zone_id": params.plant.zone?.id,
          "details": {
            "description": params.plant.details?.description,
            if (params.plant.details?.notes != null)
              "notes": params.plant.details?.notes,
            "time_to_harvest": params.plant.details?.timeToHarvest,
            "count": params.plant.details?.count,
          },
        },
      );

      return ApiResponse<PlantModel>.fromJson(
        response,
        (data) => PlantModel.fromJson(data as Map<String, dynamic>),
      );
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<PlantModel>> editPlant(EditPlantParams params) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.patch(
        '/gardens/${params.gardenId}/plants/${params.plantId}',
        data: {
          "name": params.plant.name,
          "zone_id": params.plant.zone?.id,
          "details": {
            "description": params.plant.details?.description,
            if (params.plant.details?.notes != null)
              "notes": params.plant.details?.notes,
            "time_to_harvest": params.plant.details?.timeToHarvest,
            "count": params.plant.details?.count,
          },
        },
      );

      // final response = {
      //   "status": "success",
      //   "code": 200,
      //   "message": "Plant updated successfully",
      //   "data": plant.toJson(),
      // };

      return ApiResponse<PlantModel>.fromJson(
        response,
        (data) => PlantModel.fromJson(data as Map<String, dynamic>),
      );
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<String>> deletePlant(DeletePlantParams params) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.delete(
        '/gardens/${params.gardenId}/plants/${params.plantId}',
      );

      return ApiResponse<String>.fromJson(response, (data) => data as String);
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }
}
