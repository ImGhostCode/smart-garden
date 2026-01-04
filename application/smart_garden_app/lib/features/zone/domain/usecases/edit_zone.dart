// Get Zone By ID Use Case
// Business logic for retrieving a specific zone entity

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/zone_entity.dart';
import '../repositories/zone_repository.dart';

class EditZone implements UseCase<ZoneEntity, ZoneEntity> {
  final ZoneRepository repository;

  EditZone(this.repository);

  @override
  Future<Either<Failure, ZoneEntity>> call(ZoneEntity zone) {
    return repository.editZone(zone);
  }
}

class ZoneParams extends Equatable {
  final String id;

  const ZoneParams({required this.id});

  @override
  List<Object> get props => [id];
}
