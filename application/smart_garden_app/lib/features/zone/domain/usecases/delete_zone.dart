// Get All Zones Use Case
// Business logic for retrieving all zone entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/zone_repository.dart';

class DeleteZone implements UseCase<ApiResponse<String>, DeleteZoneParams> {
  final ZoneRepository repository;

  DeleteZone(this.repository);

  @override
  Future<Either<Failure, ApiResponse<String>>> call(DeleteZoneParams params) {
    return repository.deleteZone(params);
  }
}

class DeleteZoneParams {
  final String? id;
  final String? gardenId;
  DeleteZoneParams({required this.id, required this.gardenId});
}
