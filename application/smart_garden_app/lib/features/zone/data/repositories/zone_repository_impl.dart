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
}
