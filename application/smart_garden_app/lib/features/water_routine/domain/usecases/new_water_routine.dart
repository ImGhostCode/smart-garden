// ignore_for_file: public_member_api_docs, sort_constructors_first
// Get All WaterSchedules Use Case
// Business logic for retrieving all waterSchedule entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/water_routine_entity.dart';
import '../repositories/water_routine_repository.dart';

class NewWaterRoutine
    implements UseCase<WaterRoutineEntity, WaterRoutineEntity> {
  final WaterRoutineRepository repository;

  NewWaterRoutine(this.repository);

  @override
  Future<Either<Failure, WaterRoutineEntity>> call(WaterRoutineEntity params) {
    return repository.newWaterRoutine(params);
  }
}
