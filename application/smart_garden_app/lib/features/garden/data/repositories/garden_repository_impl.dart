// Garden Repository Implementation
// Implements the repository interface for garden

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/garden_entity.dart';
import '../../domain/repositories/garden_repository.dart';
import '../../domain/usecases/get_all_gardens.dart';
import '../../domain/usecases/send_garden_action.dart';
import '../datasources/garden_local_datasource.dart';
import '../datasources/garden_remote_datasource.dart';
import '../models/garden_model.dart';

class GardenRepositoryImpl implements GardenRepository {
  final GardenRemoteDataSource remoteDataSource;
  final GardenLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  GardenRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ApiResponse<List<GardenEntity>>>> getAllGardens(
    GetAllGardenParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getAllGardens(params);
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        localDataSource.cacheGardens(response.data ?? []);
        return Right(
          ApiResponse<List<GardenEntity>>(
            status: response.status,
            code: response.code,
            message: response.message,
            data: response.data!.map((e) => e.toEntity()).toList(),
          ),
        );
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on NetworkException {
        return const Left(NetworkFailure());
      } on Exception {
        return const Left(ServerFailure());
      }
    } else {
      try {
        final localGardens = await localDataSource.getCachedGardens();
        return Right(
          ApiResponse<List<GardenEntity>>(
            status: "success",
            code: 200,
            message: "Gardens retrieved from cache",
            data: localGardens.map((e) => e.toEntity()).toList(),
          ),
        );
      } catch (e) {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, ApiResponse<GardenEntity>>> getGardenById(
    String id,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getGardenById(id);
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<GardenEntity>(
            status: response.status,
            code: response.code,
            message: response.message,
            data: response.data!.toEntity(),
          ),
        );
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on NetworkException {
        return const Left(NetworkFailure());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ApiResponse<GardenEntity>>> createGarden(
    GardenEntity garden,
  ) async {
    try {
      final response = await remoteDataSource.createGarden(
        GardenModel.fromEntity(garden),
      );
      if (response.status != "success") {
        return Left(ServerFailure(message: response.message));
      }
      return Right(
        ApiResponse<GardenEntity>(
          status: response.status,
          code: response.code,
          message: response.message,
          data: response.data!.toEntity(),
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ApiResponse<GardenEntity>>> editGarden(
    GardenEntity garden,
  ) async {
    try {
      final response = await remoteDataSource.editGarden(
        GardenModel.fromEntity(garden),
      );
      if (response.status != "success") {
        return Left(ServerFailure(message: response.message));
      }
      return Right(
        ApiResponse<GardenEntity>(
          status: response.status,
          code: response.code,
          message: response.message,
          data: response.data!.toEntity(),
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ApiResponse<String>>> deleteGarden(String id) async {
    try {
      final response = await remoteDataSource.deleteGarden(id);
      if (response.status != "success") {
        return Left(ServerFailure(message: response.message));
      }
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ApiResponse<void>>> sendAction(
    GardenActionParams params,
  ) async {
    try {
      final response = await remoteDataSource.sendAction(params);
      if (response.status != "success") {
        return Left(ServerFailure(message: response.message));
      }
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}
