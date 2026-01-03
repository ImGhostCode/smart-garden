// WeatherClient Repository Implementation
// Implements the repository interface for weather_client

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../zone/domain/entities/zone_entity.dart';
import '../../domain/entities/weather_client_entity.dart';
import '../../domain/repositories/weather_client_repository.dart';
import '../../domain/usecases/get_all_weather_clients.dart';
import '../../domain/usecases/get_weather_client_by_id.dart';
import '../datasources/weather_client_local_datasource.dart';
import '../datasources/weather_client_remote_datasource.dart';
import '../models/weather_client_model.dart';

class WeatherClientRepositoryImpl implements WeatherClientRepository {
  final WeatherClientRemoteDataSource remoteDataSource;
  final WeatherClientLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  WeatherClientRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<WeatherClientEntity>>> getAllWeatherClients(
    GetAllWeatherClientsParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteWeatherClients = await remoteDataSource
            .getAllWeatherClients(params);
        localDataSource.cacheWeatherClients(remoteWeatherClients);
        return Right(remoteWeatherClients.map((e) => e.toEntity()).toList());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      try {
        final localWeatherClients = await localDataSource
            .getCachedWeatherClients(params);
        return Right(localWeatherClients.map((e) => e.toEntity()).toList());
      } catch (e) {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, WeatherClientEntity>> getWeatherClientById(
    GetWeatherClientParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final weatherClient = await remoteDataSource.getWeatherClientById(
          params,
        );
        return Right(weatherClient.toEntity());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, WeatherDataEntity>> getWeatherData(
    String weatherClientId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final weatherData = await remoteDataSource.getWeatherData(
          weatherClientId,
        );
        return Right(weatherData.toEntity());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, WeatherClientEntity>> editWeatherClient(
    WeatherClientEntity weatherClient,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final newWC = await remoteDataSource.editWeatherClient(
          WeatherClientModel.fromEntity(weatherClient),
        );
        return Right(newWC.toEntity());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, WeatherClientEntity>> newWeatherClient(
    WeatherClientEntity weatherClient,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final newWC = await remoteDataSource.newWeatherClient(
          WeatherClientModel.fromEntity(weatherClient),
        );
        return Right(newWC.toEntity());
      } catch (e) {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
