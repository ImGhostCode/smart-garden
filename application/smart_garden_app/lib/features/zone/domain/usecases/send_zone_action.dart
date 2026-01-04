// Get All Zones Use Case
// Business logic for retrieving all zone entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/zone_repository.dart';

class SendZoneAction implements UseCase<void, ZoneActionParams> {
  final ZoneRepository repository;

  SendZoneAction(this.repository);

  @override
  Future<Either<Failure, void>> call(ZoneActionParams params) {
    return repository.sendAction(params);
  }
}

class ZoneActionParams {
  final String? zoneId;
  final WaterAction? water;

  ZoneActionParams({this.zoneId, this.water});
}

class WaterAction {
  final int? durationMs;

  WaterAction({this.durationMs});
}
