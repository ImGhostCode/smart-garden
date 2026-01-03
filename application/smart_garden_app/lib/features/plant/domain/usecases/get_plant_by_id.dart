// Get Plant By ID Use Case
// Business logic for retrieving a specific plant entity

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/plant_entity.dart';
import '../repositories/plant_repository.dart';

class GetPlantById implements UseCase<PlantEntity, PlantParams> {
  final PlantRepository repository;
  
  GetPlantById(this.repository);
  
  @override
  Future<Either<Failure, PlantEntity>> call(PlantParams params) {
    return repository.getPlantById(params.id);
  }
}

class PlantParams extends Equatable {
  final String id;
  
  const PlantParams({required this.id});
  
  @override
  List<Object> get props => [id];
}
