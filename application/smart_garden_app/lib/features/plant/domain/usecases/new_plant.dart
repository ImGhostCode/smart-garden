// Get Plant By ID Use Case
// Business logic for retrieving a specific plant entity

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/plant_entity.dart';
import '../repositories/plant_repository.dart';

class NewPlant implements UseCase<ApiResponse<PlantEntity>, PlantEntity> {
  final PlantRepository repository;

  NewPlant(this.repository);

  @override
  Future<Either<Failure, ApiResponse<PlantEntity>>> call(PlantEntity plant) {
    return repository.addPlant(plant);
  }
}

class PlantParams extends Equatable {
  final String id;

  const PlantParams({required this.id});

  @override
  List<Object> get props => [id];
}
