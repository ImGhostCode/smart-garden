// WaterRoutine Repository Implementation
// Implements the repository interface for water_routine

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
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
  Future<Either<Failure, ApiResponse<List<WaterRoutineEntity>>>>
  getAllWaterRoutines(GetAllWRParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getAllWaterRoutines(params);
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        localDataSource.cacheWaterRoutines(response.data ?? []);
        return Right(
          ApiResponse<List<WaterRoutineEntity>>(
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
        final localWaterRoutines = await localDataSource
            .getCachedWaterRoutines();
        return Right(
          ApiResponse<List<WaterRoutineEntity>>(
            status: "success",
            code: 200,
            message: "Cached water routines retrieved successfully",
            data: localWaterRoutines.map((e) => e.toEntity()).toList(),
          ),
        );
      } catch (e) {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, ApiResponse<WaterRoutineEntity>>> getWaterRoutineById(
    String id,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getWaterRoutineById(id);
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<WaterRoutineEntity>(
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
  Future<Either<Failure, ApiResponse<WaterRoutineEntity>>> editWaterRoutine(
    WaterRoutineEntity waterRoutine,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.editWaterRoutine(
          WaterRoutineModel.fromEntity(waterRoutine),
        );
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<WaterRoutineEntity>(
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
  Future<Either<Failure, ApiResponse<WaterRoutineEntity>>> newWaterRoutine(
    WaterRoutineEntity waterRoutine,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.newWaterRoutine(
          WaterRoutineModel.fromEntity(waterRoutine),
        );
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<WaterRoutineEntity>(
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
  Future<Either<Failure, ApiResponse<String>>> deleteWaterRoutine(
    String id,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.deleteWaterRoutine(id);
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
  Future<Either<Failure, ApiResponse<void>>> runWaterRoutine(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.runWaterRoutine(id);
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
