// Get All Zones Use Case
// Business logic for retrieving all zone entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/zone_repository.dart';

class SendZoneAction implements UseCase<ApiResponse<void>, ZoneActionParams> {
  final ZoneRepository repository;

  SendZoneAction(this.repository);

  @override
  Future<Either<Failure, ApiResponse<void>>> call(ZoneActionParams params) {
    return repository.sendAction(params);
  }
}

class ZoneActionParams {
  final String? gardenId;
  final String? zoneId;
  final WaterAction? water;

  ZoneActionParams({this.gardenId, this.zoneId, this.water});
}

class WaterAction {
  final int? durationMs;

  WaterAction({this.durationMs});
}
