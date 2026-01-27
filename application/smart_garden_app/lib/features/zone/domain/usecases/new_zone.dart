// Get Zone By ID Use Case
// Business logic for retrieving a specific zone entity

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/zone_entity.dart';
import '../repositories/zone_repository.dart';

class NewZone implements UseCase<ApiResponse<ZoneEntity>, NewZoneParams> {
  final ZoneRepository repository;

  NewZone(this.repository);

  @override
  Future<Either<Failure, ApiResponse<ZoneEntity>>> call(NewZoneParams params) {
    return repository.addZone(params);
  }
}

class NewZoneParams extends Equatable {
  final String? gardenId;
  final ZoneEntity zone;

  const NewZoneParams({required this.gardenId, required this.zone});

  @override
  List<Object?> get props => [gardenId, zone];
}
