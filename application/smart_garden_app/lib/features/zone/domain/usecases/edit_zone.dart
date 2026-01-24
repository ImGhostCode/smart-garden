// Get Zone By ID Use Case
// Business logic for retrieving a specific zone entity

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/zone_entity.dart';
import '../repositories/zone_repository.dart';

class EditZone implements UseCase<ApiResponse<ZoneEntity>, EditZoneParams> {
  final ZoneRepository repository;

  EditZone(this.repository);

  @override
  Future<Either<Failure, ApiResponse<ZoneEntity>>> call(EditZoneParams params) {
    return repository.editZone(params);
  }
}

class EditZoneParams extends Equatable {
  final String? id;
  final String? gardenId;
  final bool? excludeWeather;
  final ZoneEntity zone;
  const EditZoneParams({
    required this.id,
    required this.gardenId,
    required this.zone,
    this.excludeWeather = true,
  });

  @override
  List<Object?> get props => [id, gardenId, excludeWeather, zone];
}
