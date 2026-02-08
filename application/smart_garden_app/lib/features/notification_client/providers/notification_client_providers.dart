// NotificationClient Providers
// Riverpod providers for the notification_client feature

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/storage_providers.dart';
import '../../notification_client/data/datasources/notification_client_local_datasource.dart';
import '../../notification_client/data/datasources/notification_client_remote_datasource.dart';
import '../../notification_client/domain/repositories/notification_client_repository.dart';
import '../../notification_client/domain/usecases/get_all_notification_clients.dart';
import '../../notification_client/domain/usecases/get_notification_client_by_id.dart';
import '../data/repositories/notification_client_repository_impl.dart';
import '../domain/usecases/delete_notification_client.dart';
import '../domain/usecases/edit_notification_client.dart';
import '../domain/usecases/new_notification_client.dart';
import '../domain/usecases/send_notification.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Data sources
final notificationClientRemoteDataSourceProvider =
    Provider<NotificationClientRemoteDataSource>(
      (ref) =>
          NotificationClientRemoteDataSourceImpl(ref.watch(apiClientProvider)),
    );

final notificationClientLocalDataSourceProvider =
    Provider<NotificationClientLocalDataSource>(
      (ref) => NotificationClientLocalDataSourceImpl(
        ref.read(localStorageServiceProvider),
      ),
    );

// Repository
final notificationClientRepositoryProvider =
    Provider<NotificationClientRepository>(
      (ref) => NotificationClientRepositoryImpl(
        remoteDataSource: ref.read(notificationClientRemoteDataSourceProvider),
        localDataSource: ref.read(notificationClientLocalDataSourceProvider),
        networkInfo: ref.read(networkInfoProvider),
      ),
    );

// Use cases
final getAllNotificationClientsUCProvider = Provider<GetAllNotificationClients>(
  (ref) =>
      GetAllNotificationClients(ref.read(notificationClientRepositoryProvider)),
);

final getNotificationClientByIdUCProvider = Provider<GetNotificationClientById>(
  (ref) =>
      GetNotificationClientById(ref.read(notificationClientRepositoryProvider)),
);

final sendNotificationUCProvider = Provider<SendNotification>(
  (ref) => SendNotification(ref.read(notificationClientRepositoryProvider)),
);

final newNotificationClientUCProvider = Provider<NewNotificationClient>(
  (ref) =>
      NewNotificationClient(ref.read(notificationClientRepositoryProvider)),
);

final editNotificationClientUCProvider = Provider<EditNotificationClient>(
  (ref) =>
      EditNotificationClient(ref.read(notificationClientRepositoryProvider)),
);

final deleteNotificationClientUCProvider = Provider<DeleteNotificationClient>(
  (ref) =>
      DeleteNotificationClient(ref.read(notificationClientRepositoryProvider)),
);
