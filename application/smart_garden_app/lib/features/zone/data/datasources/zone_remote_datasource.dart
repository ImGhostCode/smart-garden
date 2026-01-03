// Zone Remote Data Source
// Handles API calls for zone data

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/usecases/get_all_zones.dart';
import '../../domain/usecases/get_water_history.dart';
import '../models/water_history_model.dart';
import '../models/zone_model.dart';

abstract class ZoneRemoteDataSource {
  /// Gets all zones from the API
  Future<List<ZoneModel>> getAllZones(GetAllZoneParams params);

  /// Gets a specific zone by ID from the API
  Future<ZoneModel> getZoneById(String id);

  Future<List<WaterHistoryModel>> getWaterHistory(GetWaterHistoryParams params);
}

class ZoneRemoteDataSourceImpl implements ZoneRemoteDataSource {
  // Add HTTP client dependency here

  @override
  Future<List<ZoneModel>> getAllZones(GetAllZoneParams params) async {
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

      final response = [
        if (params.gardenId == "1")
          {
            "details": {
              "description":
                  "This zone controls watering to two trees that are watered deeply",
            },
            "id": "68de8783b78657a4ab28132e",
            // "garden_id": "68de7e98ae6796d18a268a34",
            "garden": {
              "id": "68de7e98ae6796d18a268a34",
              "name": "My Smart Garden",
            },
            "name": "Trees",
            "position": 1,
            // "water_schedule_ids": [
            // "68de82101a38491918156283",
            // "68de83cb66de8a502e0e4334",
            // ],
            "water_schedules": [
              {
                "id": "68de82101a38491918156283",
                "name": "Summer Trees",
                "description": "Water shrubs every 3 days",
                "duration_ms": 2700000,
                "interval": 1,
                "start_time": "05:00",
                "active_period": {"start_month": "May", "end_month": "Dec"},
              },
              {"id": "68de83cb66de8a502e0e4334", "name": "Winter Trees"},
            ],
            "skip_count": 1,
            "end_date": null,
            "createdAt": "2025-10-02T14:09:07.350Z",
            "updatedAt": "2025-11-29T11:33:34.179Z",
            "__v": 0,
            "weather_data": {
              "rain": {"mm": 0.2, "scale_factor": 1},
              "temperature": {"celsius": 24.06, "scale_factor": 0.72},
            },
            "next_water": {
              "time": "2025-12-21T15:00:00.000Z",
              "duration_ms": 3600000,
              // "water_schedule_id": "68de82101a38491918156283",
              "water_schedule": {
                "id": "68de82101a38491918156283",
                "name": "Summer Trees",
              },
              "message": "skip_count 1 affected the time",
            },
          },
        if (params.gardenId == "1")
          {
            "details": {
              "description":
                  "This zone controls watering to two trees that are watered deeply",
            },
            "id": "68de8783b78657a4ab281c2e",
            // "garden_id": "68de7e98ae6796d18a268a34",
            "garden": {
              "id": "68de7e98ae6796d18a268a34",
              "name": "My Smart Garden",
            },
            "name": "Shrubs",
            "position": 2,
            "water_schedules": [
              // "68de82101a38491918156283",
              // "68de83cb66de8a502e0e4334",
              {
                "id": "68de82101a38491918156283",
                "name": "Summer Trees",
                "description": "Water shrubs every 3 days",
                "duration_ms": 2700000,
                "interval": 3,
                "start_time": "05:00",
                "active_period": {"start_month": "May", "end_month": "Dec"},
              },
              {
                "id": "68de83cb66de8a502e0e4334",
                "name": "Winter Trees",
                "description": "Water shrubs every 5 days",
                "duration": "45m",
                "interval": 5,
                "start_time": "22:00",
                "active_period": {"start_month": "May", "end_month": "Dec"},
              },
            ],
            "skip_count": 4,
            "end_date": null,
            "createdAt": "2025-10-02T14:09:07.350Z",
            "updatedAt": "2025-11-29T11:33:34.179Z",
            "weather_data": {
              "rain": {"mm": 424, "scale_factor": 0.2},
              "temperature": {"celsius": 24.06, "scale_factor": 0.52},
            },
            "next_water": {
              "time": "2025-12-21T15:00:00.000Z",
              "duration_ms": 3600000,
              // "water_schedule_id": "68de82101a38491918156283",
              "water_schedule": {
                "id": "68de82101a38491918156283",
                "name": "Summer Trees",
              },
              "message": "skip_count 1 affected the time",
            },
          },
        if (params.gardenId == "2")
          {
            "details": {
              "description":
                  "This zone controls watering to two trees that are watered deeply",
            },
            "id": "68de8783b38657a4ab28132e",
            // "garden_id": "68de7e98ae6796d18a268a34",
            "garden": {
              "id": "68de7e98ae6796d18a268a34",
              "name": "My Smart Garden",
            },
            "name": "Flowers",
            "position": 2,
            "water_schedules": [
              // "68de82101a38491918156283",
              // "68de83cb66de8a502e0e4334",
              {
                "id": "68de82101a38491918156283",
                "name": "Summer Trees",
                "description": "Water shrubs every 3 days",
                "duration_ms": 2700000,
                "interval": 7,
                "start_time": "05:00",
                "active_period": {"start_month": "May", "end_month": "Dec"},
              },
              {
                "id": "68de83cb66de8a502e0e4334",
                "name": "Winter Trees",
                "description": "Water shrubs every 5 days",
                "duration": "45m",
                "interval": 10,
                "start_time": "22:00",
                "active_period": {"start_month": "May", "end_month": "Dec"},
              },
            ],
            "skip_count": 4,
            "end_date": null,
            "createdAt": "2025-10-02T14:09:07.350Z",
            "updatedAt": "2025-11-29T11:33:34.179Z",
            "weather_data": {
              "rain": {"mm": 424, "scale_factor": 0.2},
              "temperature": {"celsius": 24.06, "scale_factor": 0.52},
            },
            "next_water": {
              "time": "2025-12-21T15:00:00.000Z",
              "duration_ms": 3600000,
              // "water_schedule_id": "68de82101a38491918156283",
              "water_schedule": {
                "id": "68de82101a38491918156283",
                "name": "Summer Trees",
              },
              "message": "skip_count 1 affected the time",
            },
          },
        if (params.gardenId == "2")
          {
            "details": {
              "description":
                  "This zone controls watering to two trees that are watered deeply",
            },
            "id": "68de8783b68657a7ab28132e",
            // "garden_id": "68de7e98ae6796d18a268a34",
            "garden": {
              "id": "68de7e98ae6796d18a268a34",
              "name": "My Smart Garden",
            },
            "name": "Bushes",
            "position": 2,
            "water_schedules": [
              // "68de82101a38491918156283",
              // "68de83cb66de8a502e0e4334",
              {
                "id": "68de82101a38491918156283",
                "name": "Summer Trees",
                "description": "Water shrubs every 3 days",
                "duration_ms": 2700000,
                "interval": 15,
                "start_time": "05:00",
                "active_period": {"start_month": "May", "end_month": "Dec"},
              },
              {
                "id": "68de83cb66de8a502e0e4334",
                "name": "Winter Trees",
                "description": "Water shrubs every 5 days",
                "duration": "45m",
                "interval": 11,
                "start_time": "22:00",
                "active_period": {"start_month": "May", "end_month": "Dec"},
              },
            ],
            "skip_count": 4,
            "end_date": null,
            "createdAt": "2025-10-02T14:09:07.350Z",
            "updatedAt": "2025-11-29T11:33:34.179Z",
            "weather_data": {
              "rain": {"mm": 424, "scale_factor": 0.2},
              "temperature": {"celsius": 24.06, "scale_factor": 0.52},
            },
            "next_water": {
              "time": "2025-12-21T15:00:00.000Z",
              "duration_ms": 3600000,
              // "water_schedule_id": "68de82101a38491918156283",
              "water_schedule": {
                "id": "68de82101a38491918156283",
                "name": "Summer Trees",
              },
              "message": "skip_count 1 affected the time",
            },
          },
        if (params.gardenId == "2")
          {
            "details": {
              "description":
                  "This zone controls watering to two trees that are watered deeply",
            },
            "id": "68de8783b38657a2ab28132e",
            // "garden_id": "68de7e98ae6796d18a268a34",
            "garden": {
              "id": "68de7e98ae6796d18a268a34",
              "name": "My Smart Garden",
            },
            "name": "Bushes",
            "position": 2,
            "water_schedules": [
              // "68de82101a38491918156283",
              // "68de83cb66de8a502e0e4334",
              {
                "id": "68de82101a38491918156283",
                "name": "Summer Trees",
                "description": "Water shrubs every 3 days",
                "duration_ms": 2700000,
                "interval": 13,
                "start_time": "05:00",
                "active_period": {"start_month": "May", "end_month": "Dec"},
              },
              {
                "id": "68de83cb66de8a502e0e4334",
                "name": "Winter Trees",
                "description": "Water shrubs every 5 days",
                "duration": "45m",
                "interval": 12,
                "start_time": "22:00",
                "active_period": {"start_month": "May", "end_month": "Dec"},
              },
            ],
            "skip_count": 4,
            "end_date": null,
            "createdAt": "2025-10-02T14:09:07.350Z",
            "updatedAt": "2025-11-29T11:33:34.179Z",
            "weather_data": {
              "rain": {"mm": 424, "scale_factor": 0.2},
              "temperature": {"celsius": 24.06, "scale_factor": 0.52},
            },
            "next_water": {
              "time": "2025-12-21T15:00:00.000Z",
              "duration_ms": 3600000,
              // "water_schedule_id": "68de82101a38491918156283",
              "water_schedule": {
                "id": "68de82101a38491918156283",
                "name": "Summer Trees",
              },
              "message": "skip_count 1 affected the time",
            },
          },
        if (params.gardenId == "2")
          {
            "details": {
              "description":
                  "This zone controls watering to two trees that are watered deeply",
            },
            "id": "68de8783b38657a7ab28135e",
            // "garden_id": "68de7e98ae6796d18a268a34",
            "garden": {
              "id": "68de7e98ae6796d18a268a34",
              "name": "My Smart Garden",
            },
            "name": "Bushes",
            "position": 2,
            "water_schedules": [
              // "68de82101a38491918156283",
              // "68de83cb66de8a502e0e4334",
              {
                "id": "68de82101a38491918156283",
                "name": "Summer Trees",
                "description": "Water shrubs every 3 days",
                "duration_ms": 2700000,
                "interval": 20,
                "start_time": "05:00",
                "active_period": {"start_month": "May", "end_month": "Dec"},
              },
              {
                "id": "68de83cb66de8a502e0e4334",
                "name": "Winter Trees",
                "description": "Water shrubs every 5 days",
                "duration": "45m",
                "interval": 14,
                "start_time": "22:00",
                "active_period": {"start_month": "May", "end_month": "Dec"},
              },
            ],
            "skip_count": 4,
            "end_date": null,
            "createdAt": "2025-10-02T14:09:07.350Z",
            "updatedAt": "2025-11-29T11:33:34.179Z",
            "weather_data": {
              "rain": {"mm": 424, "scale_factor": 0.2},
              "temperature": {"celsius": 24.06, "scale_factor": 0.52},
            },
            "next_water": {
              "time": "2025-12-21T15:00:00.000Z",
              "duration_ms": 3600000,
              // "water_schedule_id": "68de82101a38491918156283",
              "water_schedule": {
                "id": "68de82101a38491918156283",
                "name": "Summer Trees",
              },
              "message": "skip_count 1 affected the time",
            },
          },
      ];

      return response.map((e) => ZoneModel.fromJson(e)).toList();
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ZoneModel> getZoneById(String id) async {
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
        "details": {
          "description":
              "This zone controls watering to two trees that are watered deeply",
        },
        "id": "68de8783b78657a4ab281c2e",
        // "garden_id": "68de7e98ae6796d18a268a34",
        "garden": {"id": "68de7e98ae6796d18a268a34", "name": "My Smart Garden"},
        "name": "Trees",
        "position": 1,
        // "water_schedule_ids": [
        //   "68de82101a38491918156283",
        //   "68de83cb66de8a502e0e4334",
        // ],
        "water_schedules": [
          {
            "id": "68de82101a38491918156283",
            "name": "Summer Trees",
            "description": "Water shrubs every 4 hours",
            "duration_ms": 2700000,
            "interval": 10,
            "start_time": "16:00",
            "active_period": {"start_month": "May", "end_month": "Dec"},
          },
          {
            "id": "68de83cb66de8a502e0e4334",
            "name": "Winter Trees",
            "description": "Water shrubs every 5 days",
            "duration_ms": 2700000,
            "interval": 10,
            "start_time": "22:00",
          },
        ],
        "skip_count": 1,
        "end_date": null,
        "createdAt": "2025-10-02T14:09:07.350Z",
        "updatedAt": "2025-11-29T11:33:34.179Z",
        "__v": 0,
        "weather_data": {
          "rain": {"mm": 200, "scale_factor": 1},
          "temperature": {"celsius": 24.06, "scale_factor": 0.72},
        },
        "next_water": {
          "time": "2025-12-21T15:00:00.000Z",
          "duration_ms": 3600000,
          // "water_schedule_id": "68de82101a38491918156283",
          "water_schedule": {
            "id": "68de82101a38491918156283",
            "name": "Summer Trees",
          },
          "message": "skip_count 1 affected the time",
        },
      };

      return ZoneModel.fromJson(response);
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
  Future<List<WaterHistoryModel>> getWaterHistory(
    GetWaterHistoryParams params,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      await Future.delayed(const Duration(seconds: 5));

      final response = [
        {
          "event_id": "evt_001",
          "zone_id": "zone_001",
          "status": "completed",
          "source": "command",
          "duration_ms": 450000,
          "sent_at": "2025-12-01T10:00:05.000Z",
          "completed_at": "2025-12-01T11:00:05.000Z",
          "started_at": "2025-12-01T10:05:00.000Z",
          "record_time": "2025-12-01T11:00:10.000Z",
        },
        {
          "event_id": "evt_002",
          "zone_id": "zone_001",
          "status": "sent",
          "source": "scheduled",
          "duration_ms": 33500,
          "sent_at": "2025-12-05T10:00:05.000Z",
          "completed_at": null,
          "started_at": null,
          "record_time": "2025-12-05T11:00:10.000Z",
        },
        {
          "event_id": "evt_003",
          "zone_id": "zone_001",
          "status": "start",
          "source": "command",
          "duration_ms": 3604000,
          "sent_at": "2025-12-05T10:00:05.000Z",
          "completed_at": null,
          "started_at": "2025-12-05T10:05:00.000Z",
          "record_time": "2025-12-05T11:00:10.000Z",
        },
      ];

      return response.map((e) => WaterHistoryModel.fromJson(e)).toList();
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }
}
