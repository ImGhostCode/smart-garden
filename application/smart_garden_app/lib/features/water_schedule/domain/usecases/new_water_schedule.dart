// ignore_for_file: public_member_api_docs, sort_constructors_first
// Get All WaterSchedules Use Case
// Business logic for retrieving all waterSchedule entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/water_schedule_entity.dart';
import '../repositories/water_schedule_repository.dart';

class NewWaterSchedule
    implements UseCase<ApiResponse<WaterScheduleEntity>, WaterScheduleEntity> {
  final WaterScheduleRepository repository;

  NewWaterSchedule(this.repository);

  @override
  Future<Either<Failure, ApiResponse<WaterScheduleEntity>>> call(
    WaterScheduleEntity params,
  ) {
    return repository.newWaterSchedule(params);
  }
}

class NewWSParams {
  final WaterScheduleEntity waterSchedule;
  final bool? excludeWeatherData;
  NewWSParams({required this.waterSchedule, this.excludeWeatherData = true});
}
