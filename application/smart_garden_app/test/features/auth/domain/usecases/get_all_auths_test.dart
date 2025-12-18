import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_garden_app/core/usecases/usecase.dart';
import 'package:smart_garden_app/features/auth/domain/entities/user_entity.dart';
import 'package:smart_garden_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_garden_app/features/auth/domain/usecases/login_use_case.dart';

@GenerateMocks([AuthRepository])
void main() {
  late GetAllAuths usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = GetAllAuths(mockRepository);
  });

  final testEntities = [
    AuthEntity(id: 'test-id-1'),
    AuthEntity(id: 'test-id-2'),
  ];

  test('should get all auths from the repository', () async {
    when(
      mockRepository.getAllAuths(),
    ).thenAnswer((_) async => Right(testEntities));

    final result = await usecase(NoParams());

    expect(result, Right(testEntities));
    verify(mockRepository.getAllAuths());
    verifyNoMoreInteractions(mockRepository);
  });
}
