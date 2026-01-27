// Plant Repository Interface
// Defines data operations for plant

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../entities/plant_entity.dart';
import '../usecases/add_plant.dart';
import '../usecases/delete_plant.dart';
import '../usecases/edit_plant.dart';
import '../usecases/get_all_plants.dart';
import '../usecases/get_plant_by_id.dart';

abstract class PlantRepository {
  /// Gets all plant entities
  Future<Either<Failure, ApiResponse<List<PlantEntity>>>> getAllPlants(
    GetAllPlantParams params,
  );

  /// Gets a specific plant entity by ID
  Future<Either<Failure, ApiResponse<PlantEntity>>> getPlantById(
    GetPlantParams params,
  );

  Future<Either<Failure, ApiResponse<PlantEntity>>> editPlant(
    EditPlantParams params,
  );

  Future<Either<Failure, ApiResponse<PlantEntity>>> addPlant(
    AddPlantParams params,
  );

  Future<Either<Failure, ApiResponse<String>>> deletePlant(
    DeletePlantParams params,
  );
}
