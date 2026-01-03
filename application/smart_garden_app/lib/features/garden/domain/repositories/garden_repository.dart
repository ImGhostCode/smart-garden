// Garden Repository Interface
// Defines data operations for garden

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/garden_entity.dart';
import '../usecases/get_all_gardens.dart';

abstract class GardenRepository {
  /// Gets all garden entities
  Future<Either<Failure, List<GardenEntity>>> getAllGardens(
    GetAllGardenParams params,
  );

  /// Gets a specific garden entity by ID
  Future<Either<Failure, GardenEntity>> getGardenById(String id);

  Future<Either<Failure, GardenEntity>> createGarden(GardenEntity garden);

  Future<Either<Failure, GardenEntity>> editGarden(GardenEntity garden);
}
