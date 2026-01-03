// Get All Plants Use Case
// Business logic for retrieving all plant entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/plant_entity.dart';
import '../repositories/plant_repository.dart';

class GetAllPlants implements UseCase<List<PlantEntity>, GetAllPlantParams> {
  final PlantRepository repository;

  GetAllPlants(this.repository);

  @override
  Future<Either<Failure, List<PlantEntity>>> call(GetAllPlantParams params) {
    return repository.getAllPlants(params);
  }
}

class GetAllPlantParams {
  final String? gardenId;
  final bool? endDated;

  GetAllPlantParams({this.gardenId, this.endDated = false});
}
