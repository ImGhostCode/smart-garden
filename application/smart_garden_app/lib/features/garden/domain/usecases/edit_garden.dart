// Get All Gardens Use Case
// Business logic for retrieving all garden entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/garden_entity.dart';
import '../repositories/garden_repository.dart';

class EditGarden implements UseCase<GardenEntity, GardenEntity> {
  final GardenRepository repository;

  EditGarden(this.repository);

  @override
  Future<Either<Failure, GardenEntity>> call(GardenEntity garden) {
    return repository.editGarden(garden);
  }
}
