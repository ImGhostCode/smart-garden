// WaterRoutine Repository Implementation
// Implements the repository interface for water_routine

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/water_routine_entity.dart';
import '../../domain/repositories/water_routine_repository.dart';
import '../../domain/usecases/get_all_water_routines.dart';
import '../datasources/water_routine_local_datasource.dart';
import '../datasources/water_routine_remote_datasource.dart';
import '../models/water_routine_model.dart';

class WaterRoutineRepositoryImpl implements WaterRoutineRepository {
  final WaterRoutineRemoteDataSource remoteDataSource;
  final WaterRoutineLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  WaterRoutineRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<WaterRoutineEntity>>> getAllWaterRoutines(
    GetAllWRParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteWaterRoutines = await remoteDataSource.getAllWaterRoutines(
          params,
        );
        localDataSource.cacheWaterRoutines(remoteWaterRoutines);
        return Right(remoteWaterRoutines.map((e) => e.toEntity()).toList());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      try {
        final localWaterRoutines = await localDataSource
            .getCachedWaterRoutines();
        return Right(localWaterRoutines.map((e) => e.toEntity()).toList());
      } catch (e) {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, WaterRoutineEntity>> getWaterRoutineById(
    String id,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final waterRoutine = await remoteDataSource.getWaterRoutineById(id);
        return Right(waterRoutine.toEntity());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, WaterRoutineEntity>> editWaterRoutine(
    WaterRoutineEntity waterRoutine,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final editedWR = await remoteDataSource.editWaterRoutine(
          WaterRoutineModel.fromEntity(waterRoutine),
        );
        return Right(editedWR.toEntity());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, WaterRoutineEntity>> newWaterRoutine(
    WaterRoutineEntity waterRoutine,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final newWR = await remoteDataSource.newWaterRoutine(
          WaterRoutineModel.fromEntity(waterRoutine),
        );
        return Right(newWR.toEntity());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
