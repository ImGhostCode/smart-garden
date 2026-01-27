// Get All Plants Use Case
// Business logic for retrieving all plant entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/plant_repository.dart';

class DeletePlant implements UseCase<ApiResponse<String>, DeletePlantParams> {
  final PlantRepository repository;

  DeletePlant(this.repository);

  @override
  Future<Either<Failure, ApiResponse<String>>> call(DeletePlantParams params) {
    return repository.deletePlant(params);
  }
}

class DeletePlantParams {
  final String? gardenId;
  final String? plantId;

  DeletePlantParams({required this.gardenId, required this.plantId});
}
