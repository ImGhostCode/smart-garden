// Get All Gardens Use Case
// Business logic for retrieving all garden entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/garden_repository.dart';

class SendGardenAction
    implements UseCase<ApiResponse<void>, GardenActionParams> {
  final GardenRepository repository;

  SendGardenAction(this.repository);

  @override
  Future<Either<Failure, ApiResponse<void>>> call(GardenActionParams params) {
    return repository.sendAction(params);
  }
}

class GardenActionParams {
  final String? gardenId;
  final LightAction? light;
  final StopAction? stop;

  GardenActionParams({this.gardenId, this.light, this.stop});
}

class LightAction {
  final String? state;
  final String? forDuration;

  LightAction({this.state, this.forDuration});
}

class StopAction {
  final bool? all;

  StopAction({this.all});
}
