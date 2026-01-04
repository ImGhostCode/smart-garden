// ignore_for_file: public_member_api_docs, sort_constructors_first
// Get All WaterRoutines Use Case
// Business logic for retrieving all waterSchedule entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/water_routine_entity.dart';
import '../repositories/water_routine_repository.dart';

class EditWaterRoutine
    implements UseCase<ApiResponse<WaterRoutineEntity>, WaterRoutineEntity> {
  final WaterRoutineRepository repository;

  EditWaterRoutine(this.repository);

  @override
  Future<Either<Failure, ApiResponse<WaterRoutineEntity>>> call(
    WaterRoutineEntity params,
  ) {
    return repository.editWaterRoutine(params);
  }
}
