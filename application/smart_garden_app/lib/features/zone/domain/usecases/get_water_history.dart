// Get Zone By ID Use Case
// Business logic for retrieving a specific zone entity

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/water_history_entity.dart';
import '../repositories/zone_repository.dart';

class GetWaterHistory
    implements
        UseCase<ApiResponse<List<WaterHistoryEntity>>, GetWaterHistoryParams> {
  final ZoneRepository repository;

  GetWaterHistory(this.repository);

  @override
  Future<Either<Failure, ApiResponse<List<WaterHistoryEntity>>>> call(
    GetWaterHistoryParams params,
  ) {
    return repository.getWaterHistory(params);
  }
}

class GetWaterHistoryParams extends Equatable {
  final String? gardenId;
  final String? zoneId;
  final String range;
  final int limit;

  const GetWaterHistoryParams({
    this.gardenId,
    this.zoneId,
    required this.range,
    required this.limit,
  });

  @override
  List<Object?> get props => [gardenId, zoneId, range, limit];
}
