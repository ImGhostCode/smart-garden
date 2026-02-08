// Get All NotificationClients Use Case
// Business logic for retrieving all weather_client entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_client_repository.dart';

class DeleteNotificationClient implements UseCase<ApiResponse<String>, String> {
  final NotificationClientRepository repository;

  DeleteNotificationClient(this.repository);

  @override
  Future<Either<Failure, ApiResponse<String>>> call(String id) {
    return repository.deleteNotificationClient(id);
  }
}
