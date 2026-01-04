// Get All WaterSchedules Use Case
// Business logic for retrieving all water_schedule entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/water_schedule_repository.dart';

class DeleteWaterSchedule implements UseCase<ApiResponse<String>, String> {
  final WaterScheduleRepository repository;

  DeleteWaterSchedule(this.repository);

  @override
  Future<Either<Failure, ApiResponse<String>>> call(String id) {
    return repository.deleteWaterSchedule(id);
  }
}
