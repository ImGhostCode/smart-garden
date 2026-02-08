import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/notification_client_entity.dart';
import '../../domain/usecases/get_all_notification_clients.dart';
import '../../domain/usecases/get_notification_client_by_id.dart';
import '../../domain/usecases/send_notification.dart';
import '../../providers/notification_client_providers.dart';

class NotificationClientState {
  final bool isLoadingNCs;
  final List<NotificationClientEntity> notiClients;
  final String errLoadingNCs;

  final bool isLoadingNC;
  final NotificationClientEntity? notifClient;
  final String errLoadingNC;

  final bool isSendingNoti;
  final String errSendingNoti;

  final bool isCreatingNC;
  final String errCreatingNC;

  final bool isEditingNC;
  final String errEditingNC;

  final bool isDeletingNC;
  final String errDeletingNC;

  final String? responseMsg;

  const NotificationClientState({
    this.isLoadingNCs = false,
    this.isLoadingNC = false,
    this.isSendingNoti = false,
    this.isCreatingNC = false,
    this.isEditingNC = false,
    this.isDeletingNC = false,
    this.notiClients = const [],
    this.notifClient,
    this.responseMsg,
    this.errLoadingNCs = "",
    this.errLoadingNC = "",
    this.errSendingNoti = "",
    this.errCreatingNC = "",
    this.errEditingNC = "",
    this.errDeletingNC = "",
  });

  NotificationClientState copyWith({
    bool? isLoadingNCs,
    bool? isLoadingNC,
    bool? isSendingNoti,
    bool? isCreatingNC,
    bool? isEditingNC,
    bool? isDeletingNC,
    List<NotificationClientEntity>? notiClients,
    NotificationClientEntity? Function()? notifClient,
    String? responseMsg,
    String? errLoadingNCs,
    String? errLoadingNC,
    String? errLoadingNotification,
    String? errCreatingNC,
    String? errEditingNC,
    String? errDeletingNC,
  }) {
    return NotificationClientState(
      isLoadingNCs: isLoadingNCs ?? this.isLoadingNCs,
      isLoadingNC: isLoadingNC ?? this.isLoadingNC,
      isSendingNoti: isSendingNoti ?? this.isSendingNoti,
      isCreatingNC: isCreatingNC ?? this.isCreatingNC,
      isEditingNC: isEditingNC ?? this.isEditingNC,
      isDeletingNC: isDeletingNC ?? this.isDeletingNC,
      notiClients: notiClients ?? this.notiClients,
      notifClient: notifClient != null ? notifClient() : this.notifClient,
      errLoadingNCs: errLoadingNCs ?? this.errLoadingNCs,
      errLoadingNC: errLoadingNC ?? this.errLoadingNC,
      errSendingNoti: errLoadingNotification ?? errSendingNoti,
      errCreatingNC: errCreatingNC ?? this.errCreatingNC,
      errEditingNC: errEditingNC ?? this.errEditingNC,
      errDeletingNC: errDeletingNC ?? this.errDeletingNC,
      responseMsg: responseMsg,
    );
  }
}

// Auth notifier
class NotificationClientNotifier extends Notifier<NotificationClientState> {
  @override
  NotificationClientState build() {
    return const NotificationClientState();
  }

  Future<void> getAllNotificationClients(
    GetAllNotificationClientsParams params,
  ) async {
    state = state.copyWith(
      isLoadingNCs: true,
      errLoadingNCs: '',
      notiClients: [],
    );

    final getAllNotificationClients = ref.read(
      getAllNotificationClientsUCProvider,
    );
    final result = await getAllNotificationClients.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingNCs: false,
        errLoadingNCs: failure.message,
      ),
      (response) => state = state.copyWith(
        isLoadingNCs: false,
        notiClients: response.data,
      ),
    );
  }

  Future<void> getNotificationClientById(
    GetNotificationClientParams params,
  ) async {
    state = state.copyWith(
      isLoadingNC: true,
      errLoadingNC: '',
      notifClient: () => null,
    );

    final getNotificationClientById = ref.read(
      getNotificationClientByIdUCProvider,
    );
    final result = await getNotificationClientById.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingNC: false,
        errLoadingNC: failure.message,
      ),
      (response) => state = state.copyWith(
        isLoadingNC: false,
        notifClient: () => response.data,
      ),
    );
  }

  Future<void> sendNotification(SendNotificationParams params) async {
    state = state.copyWith(isSendingNoti: true, errLoadingNotification: '');

    final notificationClient = ref.read(sendNotificationUCProvider);
    final result = await notificationClient.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isSendingNoti: false,
        errLoadingNotification: failure.message,
      ),
      (response) => state = state.copyWith(
        isSendingNoti: false,
        responseMsg: response.message,
      ),
    );
  }

  Future<void> newNotificationClient(
    NotificationClientEntity notifClient,
  ) async {
    state = state.copyWith(isCreatingNC: true, errCreatingNC: '');

    final newNotificationClient = ref.read(newNotificationClientUCProvider);
    final result = await newNotificationClient.call(notifClient);

    result.fold(
      (failure) => state = state.copyWith(
        isCreatingNC: false,
        errCreatingNC: failure.message,
      ),
      (response) => state = state.copyWith(
        isCreatingNC: false,
        responseMsg: response.message,
      ),
    );
  }

  Future<void> editNotificationClient(NotificationClientEntity idClient) async {
    state = state.copyWith(isEditingNC: true, errEditingNC: '');

    final editNotificationClient = ref.read(editNotificationClientUCProvider);
    final result = await editNotificationClient.call(idClient);

    result.fold(
      (failure) => state = state.copyWith(
        isEditingNC: false,
        errEditingNC: failure.message,
      ),
      (response) => state = state.copyWith(
        isEditingNC: false,
        responseMsg: response.message,
      ),
    );
  }

  Future<void> deleteNotificationClient(String id) async {
    state = state.copyWith(isDeletingNC: true, errDeletingNC: null);

    final deleteNotificationClient = ref.read(
      deleteNotificationClientUCProvider,
    );
    final result = await deleteNotificationClient.call(id);

    result.fold(
      (failure) => state = state.copyWith(
        isDeletingNC: false,
        errDeletingNC: failure.message,
      ),
      (response) => state = state.copyWith(
        isDeletingNC: false,
        responseMsg: response.message,
      ),
    );
  }
}

// Auth provider
final notiClientProvider =
    NotifierProvider<NotificationClientNotifier, NotificationClientState>(
      NotificationClientNotifier.new,
    );
