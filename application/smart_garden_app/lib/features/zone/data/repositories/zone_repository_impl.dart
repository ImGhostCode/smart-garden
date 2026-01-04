// Zone Repository Implementation
// Implements the repository interface for zone

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/water_history_entity.dart';
import '../../domain/entities/zone_entity.dart';
import '../../domain/repositories/zone_repository.dart';
import '../../domain/usecases/get_all_zones.dart';
import '../../domain/usecases/get_water_history.dart';
import '../../domain/usecases/send_zone_action.dart';
import '../datasources/zone_local_datasource.dart';
import '../datasources/zone_remote_datasource.dart';
import '../models/zone_model.dart';

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
  Future<Either<Failure, List<ZoneEntity>>> getAllZones(
    GetAllZoneParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteZones = await remoteDataSource.getAllZones(params);
        localDataSource.cacheZones(remoteZones);
        return Right(remoteZones.map((e) => e.toEntity()).toList());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      try {
        final localZones = await localDataSource.getCachedZones();
        return Right(localZones.map((e) => e.toEntity()).toList());
      } catch (e) {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, ZoneEntity>> getZoneById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final zone = await remoteDataSource.getZoneById(id);
        return Right(zone.toEntity());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<WaterHistoryEntity>>> getWaterHistory(
    GetWaterHistoryParams params,
  ) async {
    // if (await networkInfo.isConnected) {
    try {
      final remoteWaterHistory = await remoteDataSource.getWaterHistory(params);
      // localDataSource.cacheWaterHistory(remoteWaterHistory);
      return Right(remoteWaterHistory.map((e) => e.toEntity()).toList());
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
  Future<Either<Failure, ZoneEntity>> addZone(ZoneEntity zone) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedZone = await remoteDataSource.addZone(
          ZoneModel.fromEntity(zone),
        );
        return Right(updatedZone.toEntity());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ZoneEntity>> editZone(ZoneEntity zone) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedZone = await remoteDataSource.editZone(
          ZoneModel.fromEntity(zone),
        );
        return Right(updatedZone.toEntity());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> deleteZone(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.deleteZone(id);
        return Right(response);
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> sendAction(ZoneActionParams params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendAction(params);
        return const Right(null);
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
