// WeatherClient Repository Implementation
// Implements the repository interface for weather_client

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
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
  Future<Either<Failure, ApiResponse<List<WeatherClientEntity>>>>
  getAllWeatherClients(GetAllWeatherClientsParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getAllWeatherClients(params);
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        localDataSource.cacheWeatherClients(response.data ?? []);
        return Right(
          ApiResponse<List<WeatherClientEntity>>(
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
        final localWeatherClients = await localDataSource
            .getCachedWeatherClients(params);
        return Right(
          ApiResponse<List<WeatherClientEntity>>(
            status: "success",
            code: 200,
            message: "Cached weather clients retrieved successfully",
            data: localWeatherClients.map((e) => e.toEntity()).toList(),
          ),
        );
      } catch (e) {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, ApiResponse<WeatherClientEntity>>>
  getWeatherClientById(GetWeatherClientParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getWeatherClientById(params);
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<WeatherClientEntity>(
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
  Future<Either<Failure, ApiResponse<WeatherDataEntity>>> getWeatherData(
    String weatherClientId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getWeatherData(weatherClientId);
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<WeatherDataEntity>(
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
  Future<Either<Failure, ApiResponse<WeatherClientEntity>>> editWeatherClient(
    WeatherClientEntity weatherClient,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.editWeatherClient(
          WeatherClientModel.fromEntity(weatherClient),
        );
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<WeatherClientEntity>(
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
  Future<Either<Failure, ApiResponse<WeatherClientEntity>>> newWeatherClient(
    WeatherClientEntity weatherClient,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.newWeatherClient(
          WeatherClientModel.fromEntity(weatherClient),
        );
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<WeatherClientEntity>(
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
  Future<Either<Failure, ApiResponse<String>>> deleteWeatherClient(
    String id,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.deleteWeatherClient(id);
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
