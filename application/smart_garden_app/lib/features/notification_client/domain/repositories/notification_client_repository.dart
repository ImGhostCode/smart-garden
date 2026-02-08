// NotificationClient Repository Interface
// Defines data operations for notification_client

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../entities/notification_client_entity.dart';
import '../usecases/get_all_notification_clients.dart';
import '../usecases/get_notification_client_by_id.dart';
import '../usecases/send_notification.dart';

abstract class NotificationClientRepository {
  /// Gets all notificationClient entities
  Future<Either<Failure, ApiResponse<List<NotificationClientEntity>>>>
  getAllNotificationClients(GetAllNotificationClientsParams params);

  /// Gets a specific notificationClient entity by ID
  Future<Either<Failure, ApiResponse<NotificationClientEntity>>>
  getNotificationClientById(GetNotificationClientParams params);

  Future<Either<Failure, ApiResponse<void>>> sendNotification(
    SendNotificationParams params,
  );

  Future<Either<Failure, ApiResponse<NotificationClientEntity>>>
  newNotificationClient(NotificationClientEntity notificationClient);

  Future<Either<Failure, ApiResponse<NotificationClientEntity>>>
  editNotificationClient(NotificationClientEntity notificationClient);

  Future<Either<Failure, ApiResponse<String>>> deleteNotificationClient(
    String id,
  );
}
