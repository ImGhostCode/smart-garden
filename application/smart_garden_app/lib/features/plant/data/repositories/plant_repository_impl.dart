// Plant Repository Implementation
// Implements the repository interface for plant

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/plant_entity.dart';
import '../../domain/repositories/plant_repository.dart';
import '../../domain/usecases/get_all_plants.dart';
import '../datasources/plant_local_datasource.dart';
import '../datasources/plant_remote_datasource.dart';
import '../models/plant_model.dart';

class PlantRepositoryImpl implements PlantRepository {
  final PlantRemoteDataSource remoteDataSource;
  final PlantLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PlantRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ApiResponse<List<PlantEntity>>>> getAllPlants(
    GetAllPlantParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getAllPlants(params);
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        localDataSource.cachePlants(response.data ?? []);
        return Right(
          ApiResponse<List<PlantEntity>>(
            status: response.status,
            code: response.code,
            message: response.message,
            data: response.data
                ?.map((plantModel) => plantModel.toEntity())
                .toList(),
          ),
        );
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      try {
        final localPlants = await localDataSource.getCachedPlants();
        return Right(
          ApiResponse<List<PlantEntity>>(
            status: "success",
            code: 200,
            message: "Plants retrieved from cache",
            data: localPlants
                .map((plantModel) => plantModel.toEntity())
                .toList(),
          ),
        );
      } catch (e) {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, ApiResponse<PlantEntity>>> getPlantById(
    String id,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getPlantById(id);
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<PlantEntity>(
            status: response.status,
            code: response.code,
            message: response.message,
            data: response.data?.toEntity(),
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
  Future<Either<Failure, ApiResponse<PlantEntity>>> addPlant(
    PlantEntity plant,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.addPlant(
          PlantModel.fromEntity(plant),
        );
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<PlantEntity>(
            status: response.status,
            code: response.code,
            message: response.message,
            data: response.data?.toEntity(),
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
  Future<Either<Failure, ApiResponse<PlantEntity>>> editPlant(
    PlantEntity plant,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.editPlant(
          PlantModel.fromEntity(plant),
        );
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<PlantEntity>(
            status: response.status,
            code: response.code,
            message: response.message,
            data: response.data?.toEntity(),
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
  Future<Either<Failure, ApiResponse<String>>> deletePlant(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.deletePlant(id);
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<String>(
            status: response.status,
            code: response.code,
            message: response.message,
            data: response.data,
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
