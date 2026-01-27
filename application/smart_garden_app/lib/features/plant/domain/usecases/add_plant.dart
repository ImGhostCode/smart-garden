// Get Plant By ID Use Case
// Business logic for retrieving a specific plant entity

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/plant_entity.dart';
import '../repositories/plant_repository.dart';

class AddPlant implements UseCase<ApiResponse<PlantEntity>, AddPlantParams> {
  final PlantRepository repository;

  AddPlant(this.repository);

  @override
  Future<Either<Failure, ApiResponse<PlantEntity>>> call(
    AddPlantParams params,
  ) {
    return repository.addPlant(params);
  }
}

class AddPlantParams extends Equatable {
  final String? gardenId;
  final PlantEntity plant;

  const AddPlantParams({required this.gardenId, required this.plant});

  @override
  List<Object?> get props => [gardenId, plant];
}
