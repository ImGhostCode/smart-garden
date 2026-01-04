// WaterSchedule Repository Implementation
// Implements the repository interface for water_schedule

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
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
  Future<Either<Failure, ApiResponse<List<WaterScheduleEntity>>>>
  getAllWaterSchedules(GetAllWSParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getAllWaterSchedules(params);
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        localDataSource.cacheWaterSchedules(response.data ?? []);
        return Right(
          ApiResponse<List<WaterScheduleEntity>>(
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
        final localWaterSchedules = await localDataSource
            .getCachedWaterSchedules();
        return Right(
          ApiResponse<List<WaterScheduleEntity>>(
            status: "success",
            code: 200,
            message: "Cached water schedules retrieved successfully",
            data: localWaterSchedules.map((e) => e.toEntity()).toList(),
          ),
        );
      } catch (e) {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, ApiResponse<WaterScheduleEntity>>>
  getWaterScheduleById(GetWSParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getWaterScheduleById(params);
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<WaterScheduleEntity>(
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
  Future<Either<Failure, ApiResponse<WaterScheduleEntity>>> newWaterSchedule(
    WaterScheduleEntity waterSchedule,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.newWaterSchedule(
          WaterScheduleModel.fromEntity(waterSchedule),
        );
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<WaterScheduleEntity>(
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
  Future<Either<Failure, ApiResponse<WaterScheduleEntity>>> editWaterSchedule(
    WaterScheduleEntity waterSchedule,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.editWaterSchedule(
          WaterScheduleModel.fromEntity(waterSchedule),
        );
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<WaterScheduleEntity>(
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
  Future<Either<Failure, ApiResponse<String>>> deleteWaterSchedule(
    String id,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.deleteWaterSchedule(id);
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
}
