import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class CheckAuthUseCase {
  final AuthRepository _repository;

  CheckAuthUseCase(this._repository);

  Future<Either<Failure, UserEntity>> execute() async {
    final result = await _repository.isAuthenticated();

    return result.fold(
      (failure) {
        return Future.value(const Left(UnauthorizedFailure()));
      },
      (isAuthenticated) async {
        return _repository.getCurrentUser();
      },
    );
  }
}
