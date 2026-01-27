// Zone Repository Interface
// Defines data operations for zone

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../entities/water_history_entity.dart';
import '../entities/zone_entity.dart';
import '../usecases/delete_zone.dart';
import '../usecases/edit_zone.dart';
import '../usecases/get_all_zones.dart';
import '../usecases/get_water_history.dart';
import '../usecases/get_zone_by_id.dart';
import '../usecases/new_zone.dart';
import '../usecases/send_zone_action.dart';

abstract class ZoneRepository {
  /// Gets all zone entities
  Future<Either<Failure, ApiResponse<List<ZoneEntity>>>> getAllZones(
    GetAllZoneParams params,
  );

  /// Gets a specific zone entity by ID
  Future<Either<Failure, ApiResponse<ZoneEntity>>> getZoneById(
    GetZoneParams params,
  );

  Future<Either<Failure, ApiResponse<List<WaterHistoryEntity>>>>
  getWaterHistory(GetWaterHistoryParams params);

  Future<Either<Failure, ApiResponse<ZoneEntity>>> addZone(
    NewZoneParams params,
  );

  Future<Either<Failure, ApiResponse<ZoneEntity>>> editZone(
    EditZoneParams zone,
  );

  Future<Either<Failure, ApiResponse<String>>> deleteZone(DeleteZoneParams id);

  Future<Either<Failure, ApiResponse<void>>> sendAction(
    ZoneActionParams params,
  );
}
