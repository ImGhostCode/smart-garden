// WaterSchedule Repository Interface
// Defines data operations for water_schedule

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../entities/water_schedule_entity.dart';
import '../usecases/get_all_water_schedules.dart';
import '../usecases/get_water_schedule_by_id.dart';

abstract class WaterScheduleRepository {
  /// Gets all waterSchedule entities
  Future<Either<Failure, ApiResponse<List<WaterScheduleEntity>>>>
  getAllWaterSchedules(GetAllWSParams params);

  /// Gets a specific waterSchedule entity by ID
  Future<Either<Failure, ApiResponse<WaterScheduleEntity>>>
  getWaterScheduleById(GetWSParams params);

  Future<Either<Failure, ApiResponse<WaterScheduleEntity>>> newWaterSchedule(
    WaterScheduleEntity waterSchedule,
  );

  Future<Either<Failure, ApiResponse<WaterScheduleEntity>>> editWaterSchedule(
    WaterScheduleEntity waterSchedule,
  );

  Future<Either<Failure, ApiResponse<String>>> deleteWaterSchedule(String id);
}
