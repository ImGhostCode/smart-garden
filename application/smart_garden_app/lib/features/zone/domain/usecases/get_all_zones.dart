// ignore_for_file: public_member_api_docs, sort_constructors_first
// Get All Zones Use Case
// Business logic for retrieving all zone entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/zone_entity.dart';
import '../repositories/zone_repository.dart';

class GetAllZones
    implements UseCase<ApiResponse<List<ZoneEntity>>, GetAllZoneParams> {
  final ZoneRepository repository;

  GetAllZones(this.repository);

  @override
  Future<Either<Failure, ApiResponse<List<ZoneEntity>>>> call(
    GetAllZoneParams params,
  ) {
    return repository.getAllZones(params);
  }
}

class GetAllZoneParams {
  final String? gardenId;
  final bool? endDated;
  final bool? excludeWeather;
  GetAllZoneParams({
    this.gardenId,
    this.endDated = false,
    this.excludeWeather = true,
  });
}
