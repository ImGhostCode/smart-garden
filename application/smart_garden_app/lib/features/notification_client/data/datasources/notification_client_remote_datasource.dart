// NotificationClient Remote Data Source
// Handles API calls for notification_client data

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/usecases/get_all_notification_clients.dart';
import '../../domain/usecases/get_notification_client_by_id.dart';
import '../../domain/usecases/send_notification.dart';
import '../models/notification_client_model.dart';

abstract class NotificationClientRemoteDataSource {
  /// Gets all notificationClients from the API
  Future<ApiResponse<List<NotificationClientModel>>> getAllNotificationClients(
    GetAllNotificationClientsParams params,
  );

  /// Gets a specific notificationClient by ID from the API
  Future<ApiResponse<NotificationClientModel>> getNotificationClientById(
    GetNotificationClientParams params,
  );

  Future<ApiResponse<void>> sendNotification(SendNotificationParams params);

  Future<ApiResponse<NotificationClientModel>> newNotificationClient(
    NotificationClientModel notificationClient,
  );

  Future<ApiResponse<NotificationClientModel>> editNotificationClient(
    NotificationClientModel notificationClient,
  );

  Future<ApiResponse<String>> deleteNotificationClient(String id);
}

class NotificationClientRemoteDataSourceImpl
    implements NotificationClientRemoteDataSource {
  final ApiClient _apiClient;

  NotificationClientRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ApiResponse<List<NotificationClientModel>>> getAllNotificationClients(
    GetAllNotificationClientsParams params,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.get(
        '/notification_clients',
        queryParameters: {'end_dated': params.endDated},
      );

      return ApiResponse<List<NotificationClientModel>>.fromJson(response, (
        data,
      ) {
        return (data as List)
            .map((e) => NotificationClientModel.fromJson(e))
            .toList();
      });
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<NotificationClientModel>> getNotificationClientById(
    GetNotificationClientParams params,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.get(
        '/notification_clients/${params.id}',
      );

      return ApiResponse<NotificationClientModel>.fromJson(
        response,
        (data) =>
            NotificationClientModel.fromJson(data as Map<String, dynamic>),
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
  Future<ApiResponse<void>> sendNotification(
    SendNotificationParams params,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.post(
        '/notification_clients/${params.id}/test',
        data: {"title": params.title, "message": params.message},
      );

      return ApiResponse<void>.fromJson(response, (data) {});
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<NotificationClientModel>> newNotificationClient(
    NotificationClientModel notificationClient,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.post(
        '/notification_clients',
        data: {
          'name': notificationClient.name,
          'type': notificationClient.type,
          'options': notificationClient.options?.toJson(),
        },
      );

      return ApiResponse<NotificationClientModel>.fromJson(
        response,
        (data) =>
            NotificationClientModel.fromJson(data as Map<String, dynamic>),
      );
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<NotificationClientModel>> editNotificationClient(
    NotificationClientModel notificationClient,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.patch(
        '/notification_clients/${notificationClient.id}',
        data: {
          'name': notificationClient.name,
          'type': notificationClient.type,
          'options': notificationClient.options?.toJson(),
        },
      );

      return ApiResponse<NotificationClientModel>.fromJson(
        response,
        (data) =>
            NotificationClientModel.fromJson(data as Map<String, dynamic>),
      );
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<ApiResponse<String>> deleteNotificationClient(String id) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.delete('/notification_clients/$id');

      return ApiResponse<String>.fromJson(response, (data) => data as String);
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }
}
