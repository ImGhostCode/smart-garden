// Get Plant By ID Use Case
// Business logic for retrieving a specific plant entity

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/plant_entity.dart';
import '../repositories/plant_repository.dart';

class GetPlantById
    implements UseCase<ApiResponse<PlantEntity>, GetPlantParams> {
  final PlantRepository repository;

  GetPlantById(this.repository);

  @override
  Future<Either<Failure, ApiResponse<PlantEntity>>> call(
    GetPlantParams params,
  ) {
    return repository.getPlantById(params);
  }
}

class GetPlantParams extends Equatable {
  final String? gardenId;
  final String? plantId;

  const GetPlantParams({required this.gardenId, required this.plantId});

  @override
  List<Object?> get props => [gardenId, plantId];
}
