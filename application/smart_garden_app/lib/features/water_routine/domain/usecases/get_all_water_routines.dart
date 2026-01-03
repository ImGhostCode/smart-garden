// Get All WaterRoutines Use Case
// Business logic for retrieving all waterRoutine entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/water_routine_entity.dart';
import '../repositories/water_routine_repository.dart';

class GetAllWaterRoutines
    implements UseCase<List<WaterRoutineEntity>, GetAllWRParams> {
  final WaterRoutineRepository repository;

  GetAllWaterRoutines(this.repository);

  @override
  Future<Either<Failure, List<WaterRoutineEntity>>> call(
    GetAllWRParams params,
  ) {
    return repository.getAllWaterRoutines(params);
  }
}

class GetAllWRParams {
  final bool? endDated;
  GetAllWRParams({this.endDated});
}
