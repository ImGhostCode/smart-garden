// Get All WaterRoutines Use Case
// Business logic for retrieving all water_routine entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/water_routine_repository.dart';

class DeleteWaterRoutine implements UseCase<ApiResponse<String>, String> {
  final WaterRoutineRepository repository;

  DeleteWaterRoutine(this.repository);

  @override
  Future<Either<Failure, ApiResponse<String>>> call(String id) {
    return repository.deleteWaterRoutine(id);
  }
}
