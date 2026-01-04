import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  genericArgumentFactories: true,
)
class ApiResponse<T> {
  final String status;
  final int code;
  final String message;
  final T? data;
  final List<dynamic> errors;

  const ApiResponse({
    this.status = '',
    this.code = 0,
    this.message = '',
    this.data,
    this.errors = const [],
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJson,
  ) => _$ApiResponseFromJson(json, fromJson);

  Map<String, dynamic> toJson(Object? Function(T value) toJson) =>
      _$ApiResponseToJson(this, toJson);
}
