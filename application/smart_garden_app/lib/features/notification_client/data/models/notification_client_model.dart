import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/notification_client_entity.dart';

part 'notification_client_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class NotificationClientModel {
  final String? id;
  final String? name;
  final String? type;
  final OptionModel? options;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NotificationClientModel({
    this.id,
    this.name,
    this.type,
    this.options,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationClientModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationClientModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationClientModelToJson(this);

  NotificationClientEntity toEntity() {
    return NotificationClientEntity(
      id: id,
      name: name,
      type: type,
      options: options?.toEntity(),
      endDate: endDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static NotificationClientModel fromEntity(NotificationClientEntity entity) {
    return NotificationClientModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      options: entity.options != null
          ? OptionModel(
              user: entity.options!.user,
              token: entity.options!.token,
              deviceName: entity.options!.deviceName,
              createError: entity.options!.createError,
              sendMessageError: entity.options!.sendMessageError,
            )
          : null,
      endDate: entity.endDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class OptionModel {
  final String? user;
  final String? token;
  final String? createError;
  final String? deviceName;
  final String? sendMessageError;

  OptionModel({
    this.user,
    this.token,
    this.deviceName,
    this.createError,
    this.sendMessageError,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) =>
      _$OptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$OptionModelToJson(this);

  OptionEntity toEntity() {
    return OptionEntity(
      user: user,
      token: token,
      deviceName: deviceName,
      createError: createError,
      sendMessageError: sendMessageError,
    );
  }
}
