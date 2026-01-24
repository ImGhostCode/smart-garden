// Plant Repository Implementation
// Implements the repository interface for plant

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/plant_entity.dart';
import '../../domain/repositories/plant_repository.dart';
import '../../domain/usecases/add_plant.dart';
import '../../domain/usecases/delete_plant.dart';
import '../../domain/usecases/edit_plant.dart';
import '../../domain/usecases/get_all_plants.dart';
import '../../domain/usecases/get_plant_by_id.dart';
import '../datasources/plant_local_datasource.dart';
import '../datasources/plant_remote_datasource.dart';

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
    GetPlantParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getPlantById(params);
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
    AddPlantParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.addPlant(params);
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
    EditPlantParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.editPlant(params);
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
  Future<Either<Failure, ApiResponse<String>>> deletePlant(
    DeletePlantParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.deletePlant(params);
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
