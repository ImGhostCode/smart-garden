// Zone Repository Implementation
// Implements the repository interface for zone

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/water_history_entity.dart';
import '../../domain/entities/zone_entity.dart';
import '../../domain/repositories/zone_repository.dart';
import '../../domain/usecases/delete_zone.dart';
import '../../domain/usecases/edit_zone.dart';
import '../../domain/usecases/get_all_zones.dart';
import '../../domain/usecases/get_water_history.dart';
import '../../domain/usecases/get_zone_by_id.dart';
import '../../domain/usecases/new_zone.dart';
import '../../domain/usecases/send_zone_action.dart';
import '../datasources/zone_local_datasource.dart';
import '../datasources/zone_remote_datasource.dart';

class ZoneRepositoryImpl implements ZoneRepository {
  final ZoneRemoteDataSource remoteDataSource;
  final ZoneLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ZoneRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ApiResponse<List<ZoneEntity>>>> getAllZones(
    GetAllZoneParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getAllZones(params);
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        localDataSource.cacheZones(response.data ?? []);
        return Right(
          ApiResponse<List<ZoneEntity>>(
            status: response.status,
            code: response.code,
            message: response.message,
            data: response.data!.map((e) => e.toEntity()).toList(),
          ),
        );
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      try {
        final localZones = await localDataSource.getCachedZones();
        return Right(
          ApiResponse<List<ZoneEntity>>(
            status: "success",
            code: 200,
            message: "Cached zones retrieved successfully",
            data: localZones.map((e) => e.toEntity()).toList(),
          ),
        );
      } catch (e) {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, ApiResponse<ZoneEntity>>> getZoneById(
    GetZoneParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getZoneById(params);
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<ZoneEntity>(
            status: response.status,
            code: response.code,
            message: response.message,
            data: response.data!.toEntity(),
          ),
        );
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ApiResponse<List<WaterHistoryEntity>>>>
  getWaterHistory(GetWaterHistoryParams params) async {
    // if (await networkInfo.isConnected) {
    try {
      final response = await remoteDataSource.getWaterHistory(params);
      // localDataSource.cacheWaterHistory(remoteWaterHistory);
      if (response.status != "success") {
        return Left(ServerFailure(message: response.message));
      }
      return Right(
        ApiResponse<List<WaterHistoryEntity>>(
          status: response.status,
          code: response.code,
          message: response.message,
          data: response.data!.map((e) => e.toEntity()).toList(),
        ),
      );
    } catch (e) {
      return const Left(ServerFailure());
    }
    // } else {
    //   try {
    //     final localWaterHistory = await localDataSource.getCachedWaterHistory();
    //     return Right(localWaterHistory.map((e) => e.toEntity()).toList());
    //   } catch (e) {
    //     return const Left(CacheFailure());
    //   }
    // }
  }

  @override
  Future<Either<Failure, ApiResponse<ZoneEntity>>> addZone(
    NewZoneParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.addZone(params);
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<ZoneEntity>(
            status: response.status,
            code: response.code,
            message: response.message,
            data: response.data!.toEntity(),
          ),
        );
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ApiResponse<ZoneEntity>>> editZone(
    EditZoneParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.editZone(params);
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<ZoneEntity>(
            status: response.status,
            code: response.code,
            message: response.message,
            data: response.data!.toEntity(),
          ),
        );
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ApiResponse<String>>> deleteZone(
    DeleteZoneParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.deleteZone(params);
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<String>(
            status: response.status,
            code: response.code,
            message: response.message,
            data: response.data!,
          ),
        );
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ApiResponse<void>>> sendAction(
    ZoneActionParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.sendAction(params);
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<void>(
            status: response.status,
            code: response.code,
            message: response.message,
            data: null,
          ),
        );
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
