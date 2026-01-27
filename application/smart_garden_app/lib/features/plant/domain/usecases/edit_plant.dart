// Business logic for retrieving a specific plant entity

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/plant_entity.dart';
import '../repositories/plant_repository.dart';

class EditPlant implements UseCase<ApiResponse<PlantEntity>, EditPlantParams> {
  final PlantRepository repository;

  EditPlant(this.repository);

  @override
  Future<Either<Failure, ApiResponse<PlantEntity>>> call(
    EditPlantParams params,
  ) {
    return repository.editPlant(params);
  }
}

class EditPlantParams extends Equatable {
  final String? gardenId;
  final String? plantId;
  final PlantEntity plant;

  const EditPlantParams({
    required this.gardenId,
    required this.plantId,
    required this.plant,
  });

  @override
  List<Object?> get props => [gardenId, plantId, plant];
}
