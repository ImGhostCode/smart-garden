// Plant Repository Interface
// Defines data operations for plant

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../entities/plant_entity.dart';
import '../usecases/get_all_plants.dart';

abstract class PlantRepository {
  /// Gets all plant entities
  Future<Either<Failure, ApiResponse<List<PlantEntity>>>> getAllPlants(
    GetAllPlantParams params,
  );

  /// Gets a specific plant entity by ID
  Future<Either<Failure, ApiResponse<PlantEntity>>> getPlantById(String id);

  Future<Either<Failure, ApiResponse<PlantEntity>>> editPlant(
    PlantEntity plant,
  );

  Future<Either<Failure, ApiResponse<PlantEntity>>> addPlant(PlantEntity plant);

  Future<Either<Failure, ApiResponse<String>>> deletePlant(String id);
}
