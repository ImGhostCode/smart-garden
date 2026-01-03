// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import '../../../zone/domain/entities/zone_entity.dart';

class WeatherClientEntity extends Equatable {
  final String? id;
  final String? name;
  final String? type;
  final OptionEntity? options;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final WeatherDataEntity? latestWeatherData;
  final String? error;

  const WeatherClientEntity({
    this.id,
    this.name,
    this.type,
    this.options,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.latestWeatherData,
    this.error,
  });

  @override
  List<Object?> get props {
    return [
      id,
      name,
      type,
      options,
      endDate,
      createdAt,
      updatedAt,
      latestWeatherData,
      error,
    ];
  }

  WeatherClientEntity copyWith({
    String? id,
    String? name,
    String? type,
    OptionEntity? options,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    WeatherDataEntity? latestWeatherData,
    String? error,
  }) {
    return WeatherClientEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      options: options ?? this.options,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      latestWeatherData:
          latestWeatherData ??
          ((latestWeatherData == null &&
                  this.latestWeatherData != null &&
                  latestWeatherData == null)
              ? null
              : this.latestWeatherData),
      error:
          error ??
          ((error == null && this.error != null && error == null)
              ? null
              : this.error),
    );
  }
}

class OptionEntity extends Equatable {
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
  final AuthenticationEntity? authentication;
  final String? clientId;
  final String? clientSecret;

  const OptionEntity({
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

  @override
  List<Object?> get props {
    return [
      rainMm,
      rainIntervalMs,
      avgHighTemperature,
      error,
      stationId,
      stationName,
      rainModuleId,
      rainModuleType,
      outdoorModuleId,
      outdoorModuleType,
      authentication,
      clientId,
      clientSecret,
    ];
  }
}

class AuthenticationEntity extends Equatable {
  final String? refreshToken;
  final String? accessToken;
  final DateTime? expirationDate;

  const AuthenticationEntity({
    this.refreshToken,
    this.accessToken,
    this.expirationDate,
  });

  @override
  List<Object?> get props => [refreshToken, accessToken, expirationDate];
}
