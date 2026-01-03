// Get WeatherClient By ID Use Case
// Business logic for retrieving a specific weatherClient entity

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../zone/domain/entities/zone_entity.dart';
import '../repositories/weather_client_repository.dart';

class GetWeatherData implements UseCase<WeatherDataEntity, String> {
  final WeatherClientRepository repository;

  GetWeatherData(this.repository);

  @override
  Future<Either<Failure, WeatherDataEntity>> call(String weatherClientId) {
    return repository.getWeatherData(weatherClientId);
  }
}
