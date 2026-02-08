// ignore_for_file: public_member_api_docs, sort_constructors_first
// Get All WaterSchedules Use Case
// Business logic for retrieving all waterSchedule entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_client_entity.dart';
import '../repositories/notification_client_repository.dart';

class NewNotificationClient
    implements
        UseCase<
          ApiResponse<NotificationClientEntity>,
          NotificationClientEntity
        > {
  final NotificationClientRepository repository;

  NewNotificationClient(this.repository);

  @override
  Future<Either<Failure, ApiResponse<NotificationClientEntity>>> call(
    NotificationClientEntity params,
  ) {
    return repository.newNotificationClient(params);
  }
}
