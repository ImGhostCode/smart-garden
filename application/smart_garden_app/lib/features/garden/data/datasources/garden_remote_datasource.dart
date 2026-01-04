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

      // In a real app, you would make an API call here
      // For this template, we'll simulate a successful login

      // Simulating a backend call with delay
      await Future.delayed(const Duration(seconds: 1));

      // Create a mock user for demonstration
      // return UserModel(
      //   id: 'user-123',
      //   name: 'John Doe',
      //   email: email,
      //   createdAt: DateTime.now(),
      //   updatedAt: DateTime.now(),
      // );

      // In real implementation:
      // final response = await _apiClient.post('/auth/login', data: {
      //   'email': email,
      //   'password': password,
      // });
      final response = {
        "status": "success",
        "code": 200,
        "message": "Gardens retrieved successfully",
        "data": [
          {
            "id": "1",
            "name": "Front Yard",
            "topic_prefix": "front-yard",
            "max_zones": 2,
            "light_schedule": {"duration": "12h", "start_time": "21:35"},
            "end_date": null,
            "controller_config": {
              "valvePins": [32, 33],
              "pumpPins": [26, 27],
              "lightPin": 14,
              "tempHumidityPin": 12,
              "tempHumidityInterval": 60000,
            },
            "next_light_action": {
              "action": "ON",
              "time": "2025-12-04T14:35:00.000Z",
            },
            "health": {
              "status": "DOWN",
              "details": "no last contact time available",
              "last_contact": "2025-12-04T14:35:00.000Z",
            },
            "temperature_humidity_data": {
              "temperature_celsius": 33.5,
              "humidity_percentage": 46.4,
            },
            "num_plants": 5,
            "num_zones": 2,
            "plants": {
              "rel": "collection",
              "href": "/gardens/68de7e98ae6796d18a268a34/plants",
            },
            "zones": {
              "rel": "collection",
              "href": "/gardens/68de7e98ae6796d18a268a34/zones",
            },
          },
          {
            "id": "2",
            "name": "Indoor Seed Starting",
            "topic_prefix": "indoor-seed-starting",
            "max_zones": 3,
            "light_schedule": {"duration_ms": 3600000, "start_time": "21:35"},
            "end_date": null,
            "controller_config": {
              "valve_pins": [32, 33],
              "pump_pins": [26, 27],
              "light_pin": 14,
              "temp_humidity_pin": 12,
              "temp_hum_interval_ms": 60000,
            },
            "next_light_action": {
              "action": "OFF",
              "time": "2025-12-04T14:35:00.000Z",
            },
            "health": {
              "status": "UP",
              "details": "contact time available",
              "last_contact": "2025-12-04T14:35:00.000Z",
            },
            "temperature_humidity_data": {
              "temperature_celsius": 33.5,
              "humidity_percentage": 46.4,
            },
            "num_plants": 4,
            "num_zones": 5,
            "plants": {
              "rel": "collection",
              "href": "/gardens/68de7e98ae6796d18a268a34/plants",
            },
            "zones": {
              "rel": "collection",
              "href": "/gardens/68de7e98ae6796d18a268a34/zones",
            },
          },
          {
            "id": "2",
            "name": "Indoor Seed Starting",
            "topic_prefix": "indoor-seed-starting",
            "max_zones": 3,
            "light_schedule": {"duration_ms": 3600000, "start_time": "21:35"},
            "end_date": null,
            "controller_config": {
              "valve_pins": [32, 33],
              "pump_pins": [26, 27],
              "light_pin": 14,
              "temp_humidity_pin": 12,
              "temp_hum_interval_ms": 60000,
            },
            "next_light_action": {
              "action": "OFF",
              "time": "2025-12-04T14:35:00.000Z",
            },
            "health": {
              "status": "UP",
              "details": "contact time available",
              "last_contact": "2025-12-04T14:35:00.000Z",
            },
            "temperature_humidity_data": {
              "temperature_celsius": 33.5,
              "humidity_percentage": 46.4,
            },
            "num_plants": 4,
            "num_zones": 5,
            "plants": {
              "rel": "collection",
              "href": "/gardens/68de7e98ae6796d18a268a34/plants",
            },
            "zones": {
              "rel": "collection",
              "href": "/gardens/68de7e98ae6796d18a268a34/zones",
            },
          },
        ],
      };

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

      // In a real app, you would make an API call here
      // For this template, we'll simulate a successful login

      // Simulating a backend call with delay
      await Future.delayed(const Duration(seconds: 1));

      // Create a mock user for demonstration
      // return UserModel(
      //   id: 'user-123',
      //   name: 'John Doe',
      //   email: email,
      //   createdAt: DateTime.now(),
      //   updatedAt: DateTime.now(),
      // );

      // In real implementation:
      // final response = await _apiClient.post('/auth/login', data: {
      //   'email': email,
      //   'password': password,
      // });
      final response = {
        "status": "success",
        "code": 200,
        "message": "Garden retrieved successfully",
        "data": {
          "id": "68de7e98ae6796d18a268a34",
          "name": "Front Yard",
          "topic_prefix": "front-yard",
          "max_zones": 2,
          "light_schedule": {"duration_ms": 3600000, "start_time": "21:35"},
          "end_date": null,
          "controller_config": {
            "valve_pins": [32, 33],
            "pump_pins": [26, 27],
            "light_pin": 14,
            "temp_humidity_pin": 12,
            "temp_hum_interval_ms": 60000,
          },
          "next_light_action": {
            "action": "ON",
            "time": "2025-12-04T14:35:00.000Z",
          },
          "health": {
            "status": "DOWN",
            "details": "no last contact time available",
            "last_contact": "2025-12-04T14:35:00.000Z",
          },
          "temperature_humidity_data": {
            "temperature_celsius": 33.5,
            "humidity_percentage": 46.4,
          },
          "num_plants": 5,
          "num_zones": 2,
          "plants": {
            "rel": "collection",
            "href": "/gardens/68de7e98ae6796d18a268a34/plants",
          },
          "zones": {
            "rel": "collection",
            "href": "/gardens/68de7e98ae6796d18a268a34/zones",
          },
        },
      };

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

      // Simulating a backend call with delay
      print(garden.toJson());
      await Future.delayed(const Duration(seconds: 1));

      // In real implementation, you would make an API call here to create the garden
      // For this template, we'll just return the same garden object back

      final response = {
        "status": "success",
        "code": 201,
        "message": "Garden created successfully",
        "data": garden.toJson(),
      };

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

      // Simulating a backend call with delay
      print(garden.toJson());
      await Future.delayed(const Duration(seconds: 1));

      // In real implementation, you would make an API call here to edit the garden
      // For this template, we'll just return the same garden object back

      final response = {
        "status": "success",
        "code": 200,
        "message": "Garden edited successfully",
        "data": garden.toJson(),
      };
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

      // Simulating a backend call with delay
      print('Deleting garden with id: $id');
      await Future.delayed(const Duration(seconds: 1));

      // In real implementation, you would make an API call here to delete the garden
      // For this template, we'll just return the id back

      final response = {
        "status": "success",
        "code": 200,
        "message": "Garden deleted successfully",
        "data": id,
      };

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

      // Simulating a backend call with delay
      print('Sending garden action: ${params.toString()}');
      await Future.delayed(const Duration(seconds: 1));

      // In real implementation, you would make an API call here to send the action
      // For this template, we'll just complete the future

      final response = {
        "status": "success",
        "code": 200,
        "message": "Garden action sent successfully",
        "data": null,
      };
      return ApiResponse<void>.fromJson(response, (data) {});
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }
}
