// Plant Remote Data Source
// Handles API calls for plant data

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/usecases/get_all_plants.dart';
import '../models/plant_model.dart';

abstract class PlantRemoteDataSource {
  /// Gets all plants from the API
  Future<List<PlantModel>> getAllPlants(GetAllPlantParams params);

  /// Gets a specific plant by ID from the API
  Future<PlantModel> getPlantById(String id);
}

class PlantRemoteDataSourceImpl implements PlantRemoteDataSource {
  // Add HTTP client dependency here

  @override
  Future<List<PlantModel>> getAllPlants(GetAllPlantParams params) async {
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
          "name": "lettuce",
          "zone": {"id": "68de862ab78657a4ab281c2a", "name": "Front Garden"},
          "details": {
            "description": "nutritious leafy green",
            "notes": "grown from seed and planted about 6 inches apart",
            "time_to_harvest": "70 days",
            "count": 6,
          },
          "id": "9m4e2mr0ui3e8a215n4g",
          "created_at": "2025-12-06T12:01:07.236Z",
          "end_date": "2025-12-06T12:01:07.236Z",
          "next_water_time": "2025-12-06T12:01:07.236Z",
        },
        {
          "name": "carrot",
          "zone": {"id": "68de8996b78657a4ab281c37", "name": "Backyard"},
          "details": {
            "description": "carrot nutritious leafy green",
            "notes": "grown from seed and planted about 6 inches apart",
            "time_to_harvest": "30 days",
            "count": 6,
          },
          "id": "9m4e2mr0ui3e8a215n4g",
          "created_at": "2025-12-06T12:01:07.236Z",
          "end_date": "2025-12-06T12:01:07.236Z",
          "next_water_time": "2025-12-06T12:01:07.236Z",
        },
        {
          "name": "onion",
          "zone": {"id": "68de8a2eb78657a4ab281c3b", "name": "Vegetable Patch"},
          "details": {
            "description": "onion nutritious leafy green",
            "notes": "grown from seed and planted about 6 inches apart",
            "time_to_harvest": "30 days",
            "count": 6,
          },
          "id": "9m4e2mr0ui3e8a215n4g",
          "created_at": "2025-12-06T12:01:07.236Z",
          "end_date": "2025-12-06T12:01:07.236Z",
          "next_water_time": "2025-12-06T12:01:07.236Z",
        },
      ];

      return response.map((e) => PlantModel.fromJson(e)).toList();
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<PlantModel> getPlantById(String id) async {
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
        "name": "lettuce",
        "zone": {"id": "68de862ab78657a4ab281c2a", "name": "Trees"},
        "details": {
          "description": "nutritious leafy green",
          "notes": "grown from seed and planted about 6 inches apart",
          "time_to_harvest": "70 days",
          "count": 6,
        },
        "id": "9m4e2mr0ui3e8a215n4g",
        "created_at": "2025-12-06T12:01:07.236Z",
        "end_date": "2025-12-06T12:01:07.236Z",
        "next_water_time": "2025-12-06T12:01:07.236Z",
      };

      return PlantModel.fromJson(response);
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
}
