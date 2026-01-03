// Get All WeatherClients Use Case
// Business logic for retrieving all weatherClient entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/weather_client_entity.dart';
import '../repositories/weather_client_repository.dart';

class GetAllWeatherClients
    implements UseCase<List<WeatherClientEntity>, GetAllWeatherClientsParams> {
  final WeatherClientRepository repository;

  GetAllWeatherClients(this.repository);

  @override
  Future<Either<Failure, List<WeatherClientEntity>>> call(
    GetAllWeatherClientsParams params,
  ) {
    return repository.getAllWeatherClients(params);
  }
}

class GetAllWeatherClientsParams {
  final bool? endDated;
  GetAllWeatherClientsParams({this.endDated});
}
