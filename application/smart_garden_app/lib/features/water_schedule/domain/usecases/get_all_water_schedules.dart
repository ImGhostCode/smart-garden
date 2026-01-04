// ignore_for_file: public_member_api_docs, sort_constructors_first
// Get All WaterSchedules Use Case
// Business logic for retrieving all waterSchedule entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/water_schedule_entity.dart';
import '../repositories/water_schedule_repository.dart';

class GetAllWaterSchedules
    implements UseCase<ApiResponse<List<WaterScheduleEntity>>, GetAllWSParams> {
  final WaterScheduleRepository repository;

  GetAllWaterSchedules(this.repository);

  @override
  Future<Either<Failure, ApiResponse<List<WaterScheduleEntity>>>> call(
    GetAllWSParams params,
  ) {
    return repository.getAllWaterSchedules(params);
  }
}

class GetAllWSParams {
  final bool? endDated;
  final bool? excludeWeatherData;
  GetAllWSParams({this.endDated = false, this.excludeWeatherData = false});
}
