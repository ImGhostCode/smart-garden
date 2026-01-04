// WaterRoutine Repository Interface
// Defines data operations for water_routine

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../entities/water_routine_entity.dart';
import '../usecases/get_all_water_routines.dart';

abstract class WaterRoutineRepository {
  /// Gets all waterRoutine entities
  Future<Either<Failure, ApiResponse<List<WaterRoutineEntity>>>>
  getAllWaterRoutines(GetAllWRParams params);

  /// Gets a specific waterRoutine entity by ID
  Future<Either<Failure, ApiResponse<WaterRoutineEntity>>> getWaterRoutineById(
    String id,
  );

  Future<Either<Failure, ApiResponse<WaterRoutineEntity>>> newWaterRoutine(
    WaterRoutineEntity waterRoutine,
  );

  Future<Either<Failure, ApiResponse<WaterRoutineEntity>>> editWaterRoutine(
    WaterRoutineEntity waterRoutine,
  );

  Future<Either<Failure, ApiResponse<String>>> deleteWaterRoutine(String id);

  Future<Either<Failure, ApiResponse<void>>> runWaterRoutine(String id);
}
