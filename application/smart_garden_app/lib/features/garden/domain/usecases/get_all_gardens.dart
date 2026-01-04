// Get All Gardens Use Case
// Business logic for retrieving all garden entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/garden_entity.dart';
import '../repositories/garden_repository.dart';

class GetAllGardens
    implements UseCase<ApiResponse<List<GardenEntity>>, GetAllGardenParams> {
  final GardenRepository repository;

  GetAllGardens(this.repository);

  @override
  Future<Either<Failure, ApiResponse<List<GardenEntity>>>> call(
    GetAllGardenParams params,
  ) {
    return repository.getAllGardens(params);
  }
}

class GetAllGardenParams {
  final bool? endDated;
  GetAllGardenParams({this.endDated = false});
}
