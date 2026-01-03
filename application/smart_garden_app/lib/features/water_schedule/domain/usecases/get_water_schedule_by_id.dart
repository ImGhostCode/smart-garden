// Get WaterSchedule By ID Use Case
// Business logic for retrieving a specific waterSchedule entity

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/water_schedule_entity.dart';
import '../repositories/water_schedule_repository.dart';

class GetWaterScheduleById
    implements UseCase<WaterScheduleEntity, GetWSParams> {
  final WaterScheduleRepository repository;

  GetWaterScheduleById(this.repository);

  @override
  Future<Either<Failure, WaterScheduleEntity>> call(GetWSParams params) {
    return repository.getWaterScheduleById(params);
  }
}

class GetWSParams {
  final String? id;
  final bool? endDated;
  final bool? excludeWeatherData;
  GetWSParams({
    this.id,
    this.endDated = false,
    this.excludeWeatherData = false,
  });
}
