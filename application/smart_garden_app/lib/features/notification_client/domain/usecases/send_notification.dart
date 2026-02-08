// Get NotificationClient By ID Use Case
// Business logic for retrieving a specific weatherClient entity

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_client_repository.dart';

class SendNotification
    implements UseCase<ApiResponse<void>, SendNotificationParams> {
  final NotificationClientRepository repository;

  SendNotification(this.repository);

  @override
  Future<Either<Failure, ApiResponse<void>>> call(
    SendNotificationParams params,
  ) {
    return repository.sendNotification(params);
  }
}

class SendNotificationParams extends Equatable {
  final String id;
  final String title;
  final String message;

  const SendNotificationParams({
    required this.id,
    required this.title,
    required this.message,
  });

  @override
  List<Object> get props => [id, title, message];
}
