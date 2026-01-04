// Get Garden By ID Use Case
// Business logic for retrieving a specific garden entity

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/garden_entity.dart';
import '../repositories/garden_repository.dart';

class GetGardenById
    implements UseCase<ApiResponse<GardenEntity>, GardenParams> {
  final GardenRepository repository;

  GetGardenById(this.repository);

  @override
  Future<Either<Failure, ApiResponse<GardenEntity>>> call(GardenParams params) {
    return repository.getGardenById(params.id);
  }
}

class GardenParams extends Equatable {
  final String id;

  const GardenParams({required this.id});

  @override
  List<Object> get props => [id];
}
