// Get Zone By ID Use Case
// Business logic for retrieving a specific zone entity

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/zone_entity.dart';
import '../repositories/zone_repository.dart';

class GetZoneById implements UseCase<ApiResponse<ZoneEntity>, GetZoneParams> {
  final ZoneRepository repository;

  GetZoneById(this.repository);

  @override
  Future<Either<Failure, ApiResponse<ZoneEntity>>> call(GetZoneParams params) {
    return repository.getZoneById(params);
  }
}

class GetZoneParams extends Equatable {
  final String? id;
  final String? gardenId;
  final bool? excludeWeather;
  const GetZoneParams({
    required this.id,
    required this.gardenId,
    this.excludeWeather = true,
  });

  @override
  List<Object?> get props => [id, gardenId, excludeWeather];
}
