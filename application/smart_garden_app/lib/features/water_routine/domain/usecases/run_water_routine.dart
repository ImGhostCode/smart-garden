// Get All WaterRoutines Use Case
// Business logic for retrieving all water_routine entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/water_routine_repository.dart';

class RunWaterRoutine implements UseCase<ApiResponse<void>, String> {
  final WaterRoutineRepository repository;

  RunWaterRoutine(this.repository);

  @override
  Future<Either<Failure, ApiResponse<void>>> call(String id) {
    return repository.runWaterRoutine(id);
  }
}
