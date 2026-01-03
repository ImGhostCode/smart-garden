// WaterSchedule Repository Implementation
// Implements the repository interface for water_schedule

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/water_schedule_entity.dart';
import '../../domain/repositories/water_schedule_repository.dart';
import '../../domain/usecases/get_all_water_schedules.dart';
import '../../domain/usecases/get_water_schedule_by_id.dart';
import '../datasources/water_schedule_local_datasource.dart';
import '../datasources/water_schedule_remote_datasource.dart';
import '../models/water_schedule_model.dart';

class WaterScheduleRepositoryImpl implements WaterScheduleRepository {
  final WaterScheduleRemoteDataSource remoteDataSource;
  final WaterScheduleLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  WaterScheduleRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<WaterScheduleEntity>>> getAllWaterSchedules(
    GetAllWSParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteWaterSchedules = await remoteDataSource
            .getAllWaterSchedules(params);
        localDataSource.cacheWaterSchedules(remoteWaterSchedules);
        return Right(remoteWaterSchedules.map((e) => e.toEntity()).toList());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      try {
        final localWaterSchedules = await localDataSource
            .getCachedWaterSchedules();
        return Right(localWaterSchedules.map((e) => e.toEntity()).toList());
      } catch (e) {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, WaterScheduleEntity>> getWaterScheduleById(
    GetWSParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final waterSchedule = await remoteDataSource.getWaterScheduleById(
          params,
        );
        return Right(waterSchedule.toEntity());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, WaterScheduleEntity>> newWaterSchedule(
    WaterScheduleEntity waterSchedule,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final newWS = await remoteDataSource.newWaterSchedule(
          WaterScheduleModel.fromEntity(waterSchedule),
        );
        return Right(newWS.toEntity());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, WaterScheduleEntity>> editWaterSchedule(
    WaterScheduleEntity waterSchedule,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final editedWS = await remoteDataSource.editWaterSchedule(
          WaterScheduleModel.fromEntity(waterSchedule),
        );
        return Right(editedWS.toEntity());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
