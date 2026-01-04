// Get All WeatherClients Use Case
// Business logic for retrieving all weather_client entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/weather_client_repository.dart';

class DeleteWeatherClient implements UseCase<ApiResponse<String>, String> {
  final WeatherClientRepository repository;

  DeleteWeatherClient(this.repository);

  @override
  Future<Either<Failure, ApiResponse<String>>> call(String id) {
    return repository.deleteWeatherClient(id);
  }
}
