// Get All NotificationClients Use Case
// Business logic for retrieving all weatherClient entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_client_entity.dart';
import '../repositories/notification_client_repository.dart';

class GetAllNotificationClients
    implements
        UseCase<
          ApiResponse<List<NotificationClientEntity>>,
          GetAllNotificationClientsParams
        > {
  final NotificationClientRepository repository;

  GetAllNotificationClients(this.repository);

  @override
  Future<Either<Failure, ApiResponse<List<NotificationClientEntity>>>> call(
    GetAllNotificationClientsParams params,
  ) {
    return repository.getAllNotificationClients(params);
  }
}

class GetAllNotificationClientsParams {
  final bool? endDated;
  GetAllNotificationClientsParams({this.endDated = false});
}
