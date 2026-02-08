// NotificationClient Repository Implementation
// Implements the repository interface for weather_client

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/notification_client_entity.dart';
import '../../domain/repositories/notification_client_repository.dart';
import '../../domain/usecases/get_all_notification_clients.dart';
import '../../domain/usecases/get_notification_client_by_id.dart';
import '../../domain/usecases/send_notification.dart';
import '../datasources/notification_client_local_datasource.dart';
import '../datasources/notification_client_remote_datasource.dart';
import '../models/notification_client_model.dart';

class NotificationClientRepositoryImpl implements NotificationClientRepository {
  final NotificationClientRemoteDataSource remoteDataSource;
  final NotificationClientLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NotificationClientRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ApiResponse<List<NotificationClientEntity>>>>
  getAllNotificationClients(GetAllNotificationClientsParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getAllNotificationClients(
          params,
        );
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        localDataSource.cacheNotificationClients(response.data ?? []);
        return Right(
          ApiResponse<List<NotificationClientEntity>>(
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
        final localNotificationClients = await localDataSource
            .getCachedNotificationClients(params);
        return Right(
          ApiResponse<List<NotificationClientEntity>>(
            status: "success",
            code: 200,
            message: "Cached weather clients retrieved successfully",
            data: localNotificationClients.map((e) => e.toEntity()).toList(),
          ),
        );
      } catch (e) {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, ApiResponse<NotificationClientEntity>>>
  getNotificationClientById(GetNotificationClientParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getNotificationClientById(
          params,
        );
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<NotificationClientEntity>(
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
  Future<Either<Failure, ApiResponse<void>>> sendNotification(
    SendNotificationParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.sendNotification(params);
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

  @override
  Future<Either<Failure, ApiResponse<NotificationClientEntity>>>
  editNotificationClient(NotificationClientEntity weatherClient) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.editNotificationClient(
          NotificationClientModel.fromEntity(weatherClient),
        );
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<NotificationClientEntity>(
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
  Future<Either<Failure, ApiResponse<NotificationClientEntity>>>
  newNotificationClient(NotificationClientEntity weatherClient) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.newNotificationClient(
          NotificationClientModel.fromEntity(weatherClient),
        );
        if (response.status != "success") {
          return Left(ServerFailure(message: response.message));
        }
        return Right(
          ApiResponse<NotificationClientEntity>(
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
  Future<Either<Failure, ApiResponse<String>>> deleteNotificationClient(
    String id,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.deleteNotificationClient(id);
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
