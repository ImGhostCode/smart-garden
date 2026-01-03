// Plant Repository Implementation
// Implements the repository interface for plant

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/plant_entity.dart';
import '../../domain/repositories/plant_repository.dart';
import '../../domain/usecases/get_all_plants.dart';
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
  Future<Either<Failure, List<PlantEntity>>> getAllPlants(
    GetAllPlantParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remotePlants = await remoteDataSource.getAllPlants(params);
        localDataSource.cachePlants(remotePlants);
        return Right(remotePlants.map((e) => e.toEntity()).toList());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      try {
        final localPlants = await localDataSource.getCachedPlants();
        return Right(localPlants.map((e) => e.toEntity()).toList());
      } catch (e) {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, PlantEntity>> getPlantById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final plant = await remoteDataSource.getPlantById(id);
        return Right(plant.toEntity());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
