// Garden Repository Interface
// Defines data operations for garden

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../entities/garden_entity.dart';
import '../usecases/get_all_gardens.dart';
import '../usecases/send_garden_action.dart';

abstract class GardenRepository {
  /// Gets all garden entities
  Future<Either<Failure, ApiResponse<List<GardenEntity>>>> getAllGardens(
    GetAllGardenParams params,
  );

  /// Gets a specific garden entity by ID
  Future<Either<Failure, ApiResponse<GardenEntity>>> getGardenById(String id);

  Future<Either<Failure, ApiResponse<GardenEntity>>> createGarden(
    GardenEntity garden,
  );

  Future<Either<Failure, ApiResponse<GardenEntity>>> editGarden(
    GardenEntity garden,
  );

  Future<Either<Failure, ApiResponse<String>>> deleteGarden(String id);

  Future<Either<Failure, ApiResponse<void>>> sendAction(
    GardenActionParams params,
  );
}
