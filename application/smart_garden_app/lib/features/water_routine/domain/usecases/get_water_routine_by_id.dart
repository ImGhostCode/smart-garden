// Get WaterRoutine By ID Use Case
// Business logic for retrieving a specific waterRoutine entity

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/water_routine_entity.dart';
import '../repositories/water_routine_repository.dart';

class GetWaterRoutineById implements UseCase<WaterRoutineEntity, GetWRParams> {
  final WaterRoutineRepository repository;

  GetWaterRoutineById(this.repository);

  @override
  Future<Either<Failure, WaterRoutineEntity>> call(GetWRParams params) {
    return repository.getWaterRoutineById(params.id);
  }
}

class GetWRParams extends Equatable {
  final String id;

  const GetWRParams({required this.id});

  @override
  List<Object> get props => [id];
}
