// ignore_for_file: public_member_api_docs, sort_constructors_first
// Get All WeatherClients Use Case
// Business logic for retrieving all waterSchedule entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/weather_client_entity.dart';
import '../repositories/weather_client_repository.dart';

class EditWeatherClient
    implements UseCase<WeatherClientEntity, WeatherClientEntity> {
  final WeatherClientRepository repository;

  EditWeatherClient(this.repository);

  @override
  Future<Either<Failure, WeatherClientEntity>> call(
    WeatherClientEntity params,
  ) {
    return repository.editWeatherClient(params);
  }
}
