// Get All Gardens Use Case
// Business logic for retrieving all garden entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/garden_entity.dart';
import '../repositories/garden_repository.dart';

class CreateGarden implements UseCase<ApiResponse<GardenEntity>, GardenEntity> {
  final GardenRepository repository;

  CreateGarden(this.repository);

  @override
  Future<Either<Failure, ApiResponse<GardenEntity>>> call(GardenEntity garden) {
    return repository.createGarden(garden);
  }
}
