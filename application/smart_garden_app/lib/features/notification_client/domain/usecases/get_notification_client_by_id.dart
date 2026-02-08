// Get NotificationClient By ID Use Case
// Business logic for retrieving a specific weatherClient entity

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_client_entity.dart';
import '../repositories/notification_client_repository.dart';

class GetNotificationClientById
    implements
        UseCase<
          ApiResponse<NotificationClientEntity>,
          GetNotificationClientParams
        > {
  final NotificationClientRepository repository;

  GetNotificationClientById(this.repository);

  @override
  Future<Either<Failure, ApiResponse<NotificationClientEntity>>> call(
    GetNotificationClientParams params,
  ) {
    return repository.getNotificationClientById(params);
  }
}

class GetNotificationClientParams extends Equatable {
  final String id;

  const GetNotificationClientParams({required this.id});

  @override
  List<Object> get props => [id];
}
