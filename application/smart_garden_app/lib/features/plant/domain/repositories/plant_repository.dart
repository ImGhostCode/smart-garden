// Plant Repository Interface
// Defines data operations for plant

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/plant_entity.dart';
import '../usecases/get_all_plants.dart';

abstract class PlantRepository {
  /// Gets all plant entities
  Future<Either<Failure, List<PlantEntity>>> getAllPlants(
    GetAllPlantParams params,
  );

  /// Gets a specific plant entity by ID
  Future<Either<Failure, PlantEntity>> getPlantById(String id);
}
