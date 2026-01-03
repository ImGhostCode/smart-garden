// Garden Repository Implementation
// Implements the repository interface for garden

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/garden_entity.dart';
import '../../domain/repositories/garden_repository.dart';
import '../../domain/usecases/get_all_gardens.dart';
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
  Future<Either<Failure, List<GardenEntity>>> getAllGardens(
    GetAllGardenParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteGardens = await remoteDataSource.getAllGardens(params);
        localDataSource.cacheGardens(remoteGardens);
        return Right(remoteGardens.map((e) => e.toEntity()).toList());
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
        return Right(localGardens.map((e) => e.toEntity()).toList());
      } catch (e) {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, GardenEntity>> getGardenById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final garden = await remoteDataSource.getGardenById(id);
        return Right(garden.toEntity());
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
  Future<Either<Failure, GardenEntity>> createGarden(
    GardenEntity garden,
  ) async {
    try {
      final gardenModel = await remoteDataSource.createGarden(
        GardenModel.fromEntity(garden),
      );
      return Right(gardenModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, GardenEntity>> editGarden(GardenEntity garden) async {
    try {
      final gardenModel = await remoteDataSource.editGarden(
        GardenModel.fromEntity(garden),
      );
      return Right(gardenModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}
