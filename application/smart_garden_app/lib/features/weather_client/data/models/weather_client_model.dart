import 'package:json_annotation/json_annotation.dart';

import '../../../zone/data/models/zone_model.dart';
import '../../domain/entities/weather_client_entity.dart';

part 'weather_client_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class WeatherClientModel {
  final String? id;
  final String? name;
  final String? type;
  final OptionModel? options;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final WeatherDataModel? latestWeatherData;

  WeatherClientModel({
    this.id,
    this.name,
    this.type,
    this.options,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.latestWeatherData,
  });

  factory WeatherClientModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherClientModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherClientModelToJson(this);

  WeatherClientEntity toEntity() {
    return WeatherClientEntity(
      id: id,
      name: name,
      type: type,
      options: options?.toEntity(),
      endDate: endDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static WeatherClientModel fromEntity(WeatherClientEntity entity) {
    return WeatherClientModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      options: entity.options != null
          ? OptionModel(
              rainMm: entity.options!.rainMm,
              rainIntervalMs: entity.options!.rainIntervalMs,
              avgHighTemperature: entity.options!.avgHighTemperature,
              error: entity.options!.error,
              stationId: entity.options!.stationId,
              stationName: entity.options!.stationName,
              rainModuleId: entity.options!.rainModuleId,
              rainModuleType: entity.options!.rainModuleType,
              outdoorModuleId: entity.options!.outdoorModuleId,
              outdoorModuleType: entity.options!.outdoorModuleType,
              authentication: entity.options!.authentication != null
                  ? AuthenticationModel(
                      refreshToken:
                          entity.options!.authentication!.refreshToken,
                      accessToken: entity.options!.authentication!.accessToken,
                      expirationDate:
                          entity.options!.authentication!.expirationDate,
                    )
                  : null,
              clientId: entity.options!.clientId,
              clientSecret: entity.options!.clientSecret,
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
  final double? rainMm;
  final int? rainIntervalMs;
  final double? avgHighTemperature;
  final String? error;
  final String? stationId;
  final String? stationName;
  final String? rainModuleId;
  final String? rainModuleType;
  final String? outdoorModuleId;
  final String? outdoorModuleType;
  final AuthenticationModel? authentication;
  final String? clientId;
  final String? clientSecret;

  OptionModel({
    this.rainMm,
    this.rainIntervalMs,
    this.avgHighTemperature,
    this.error,
    this.stationId,
    this.stationName,
    this.rainModuleId,
    this.rainModuleType,
    this.outdoorModuleId,
    this.outdoorModuleType,
    this.authentication,
    this.clientId,
    this.clientSecret,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) =>
      _$OptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$OptionModelToJson(this);

  OptionEntity toEntity() {
    return OptionEntity(
      rainMm: rainMm,
      rainIntervalMs: rainIntervalMs,
      avgHighTemperature: avgHighTemperature,
      error: error,
      stationId: stationId,
      stationName: stationName,
      rainModuleId: rainModuleId,
      rainModuleType: rainModuleType,
      outdoorModuleId: outdoorModuleId,
      outdoorModuleType: outdoorModuleType,
      authentication: authentication,
      clientId: clientId,
      clientSecret: clientSecret,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AuthenticationModel extends AuthenticationEntity {
  const AuthenticationModel({
    super.refreshToken,
    super.accessToken,
    super.expirationDate,
  });

  factory AuthenticationModel.fromJson(Map<String, dynamic> json) =>
      _$AuthenticationModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthenticationModelToJson(this);
}
