// NotificationClient Local Data Source
// Handles local storage for notification_client data

import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../domain/usecases/get_all_notification_clients.dart';
import '../models/notification_client_model.dart';

abstract class NotificationClientLocalDataSource {
  /// Gets cached notificationClients from local storage
  Future<List<NotificationClientModel>> getCachedNotificationClients(
    GetAllNotificationClientsParams params,
  );

  /// Caches notificationClients to local storage
  Future<void> cacheNotificationClients(
    List<NotificationClientModel> notificationClients,
  );
}

class NotificationClientLocalDataSourceImpl
    implements NotificationClientLocalDataSource {
  // Add local storage dependency here
  final LocalStorageService localStorageService;

  NotificationClientLocalDataSourceImpl(this.localStorageService);

  @override
  Future<List<NotificationClientModel>> getCachedNotificationClients(
    GetAllNotificationClientsParams params,
  ) async {
    final notificationClientStrings = localStorageService.getStringList(
      AppConstants.notificationClientsKey,
    );
    if (notificationClientStrings == null) return [];

    return notificationClientStrings
        .map(
          (e) => NotificationClientModel.fromJson(
            jsonDecode(e) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<void> cacheNotificationClients(
    List<NotificationClientModel> notificationClients,
  ) async {
    final notificationClientStrings = notificationClients
        .map((e) => jsonEncode(e.toJson()))
        .toList();
    await localStorageService.setStringList(
      AppConstants.notificationClientsKey,
      notificationClientStrings,
    );
  }
}
