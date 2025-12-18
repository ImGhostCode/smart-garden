import 'package:flutter_test/flutter_test.dart';
import 'package:smart_garden_app/features/auth/data/models/user_model.dart';
import 'package:smart_garden_app/features/auth/domain/entities/user_entity.dart';

void main() {
  final authModel = const UserModel(id: 'id', name: 'name', email: 'email');

  test('should be a subclass of UserEntity', () {
    expect(authModel, isA<UserEntity>());
  });

  group('fromJson', () {
    test('should return a valid model when JSON data is valid', () {
      final Map<String, dynamic> jsonMap = {'id': 'test-id'};

      final result = UserModel.fromJson(jsonMap);

      expect(result, authModel);
    });
  });

  group('toJson', () {
    test('should return a JSON map with proper data', () {
      final result = authModel.toJson();

      final expectedMap = {'id': 'test-id'};
      expect(result, expectedMap);
    });
  });
}
