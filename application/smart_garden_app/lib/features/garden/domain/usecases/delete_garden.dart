// Get All Gardens Use Case
// Business logic for retrieving all garden entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/garden_repository.dart';

class DeleteGarden implements UseCase<ApiResponse<String>, String> {
  final GardenRepository repository;

  DeleteGarden(this.repository);

  @override
  Future<Either<Failure, ApiResponse<String>>> call(String id) {
    return repository.deleteGarden(id);
  }
}
