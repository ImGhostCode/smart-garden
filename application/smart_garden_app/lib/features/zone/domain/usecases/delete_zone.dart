// Get All Zones Use Case
// Business logic for retrieving all zone entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/zone_repository.dart';

class DeleteZone implements UseCase<String, String> {
  final ZoneRepository repository;

  DeleteZone(this.repository);

  @override
  Future<Either<Failure, String>> call(String id) {
    return repository.deleteZone(id);
  }
}
