// Zone Repository Interface
// Defines data operations for zone

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/water_history_entity.dart';
import '../entities/zone_entity.dart';
import '../usecases/get_all_zones.dart';
import '../usecases/get_water_history.dart';

abstract class ZoneRepository {
  /// Gets all zone entities
  Future<Either<Failure, List<ZoneEntity>>> getAllZones(
    GetAllZoneParams params,
  );

  /// Gets a specific zone entity by ID
  Future<Either<Failure, ZoneEntity>> getZoneById(String id);

  Future<Either<Failure, List<WaterHistoryEntity>>> getWaterHistory(
    GetWaterHistoryParams params,
  );
}
