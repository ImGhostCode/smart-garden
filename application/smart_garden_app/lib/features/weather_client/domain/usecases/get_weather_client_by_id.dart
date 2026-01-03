// Get WeatherClient By ID Use Case
// Business logic for retrieving a specific weatherClient entity

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/weather_client_entity.dart';
import '../repositories/weather_client_repository.dart';

class GetWeatherClientById
    implements UseCase<WeatherClientEntity, GetWeatherClientParams> {
  final WeatherClientRepository repository;

  GetWeatherClientById(this.repository);

  @override
  Future<Either<Failure, WeatherClientEntity>> call(
    GetWeatherClientParams params,
  ) {
    return repository.getWeatherClientById(params);
  }
}

class GetWeatherClientParams extends Equatable {
  final String id;

  const GetWeatherClientParams({required this.id});

  @override
  List<Object> get props => [id];
}
