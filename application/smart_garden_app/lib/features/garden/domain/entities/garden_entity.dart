// Garden Entity
// Core business entity for garden

import 'package:equatable/equatable.dart';

import '../../../notification_client/domain/entities/notification_client_entity.dart';

class GardenEntity extends Equatable {
  final String? id;
  final String? name;
  final String? topicPrefix;
  final int? maxZones;
  final LightScheduleEntity? lightSchedule;
  final DateTime? endDate;
  final ControllerConfigEntity? controllerConfig;
  final NextLightActionEntity? nextLightAction;
  final HealthEntity? health;
  final TempHumDataEntity? tempHumData;
  final int? numPlants;
  final int? numZones;
  final NotificationClientEntity? notificationClient;
  final NotificationSettingEntity? notificationSettings;

  const GardenEntity({
    this.id,
    this.name,
    this.topicPrefix,
    this.maxZones,
    this.lightSchedule,
    this.endDate,
    this.controllerConfig,
    this.nextLightAction,
    this.health,
    this.tempHumData,
    this.numPlants,
    this.numZones,
    this.notificationClient,
    this.notificationSettings,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    topicPrefix,
    maxZones,
    lightSchedule,
    endDate,
    controllerConfig,
    nextLightAction,
    health,
    tempHumData,
    numPlants,
    numZones,
    notificationSettings,
    notificationClient,
  ];
}

class ControllerConfigEntity extends Equatable {
  final List<int>? valvePins;
  final List<int>? pumpPins;
  final int? lightPin;
  final int? tempHumidityPin;
  final int? tempHumIntervalMs;

  const ControllerConfigEntity({
    this.valvePins,
    this.pumpPins,
    this.lightPin,
    this.tempHumidityPin,
    this.tempHumIntervalMs,
  });

  @override
  List<Object?> get props => [
    valvePins,
    pumpPins,
    lightPin,
    tempHumidityPin,
    tempHumIntervalMs,
  ];
}

class HealthEntity extends Equatable {
  final String? status;
  final String? details;
  final DateTime? lastContact;

  const HealthEntity({this.status, this.details, this.lastContact});

  @override
  List<Object?> get props => [status, details, lastContact];
}

class LightScheduleEntity extends Equatable {
  final int? durationMs;
  final String? startTime;

  const LightScheduleEntity({this.durationMs, this.startTime});

  @override
  List<Object?> get props => [durationMs, startTime];
}

class NextLightActionEntity extends Equatable {
  final String? action;
  final DateTime? time;

  const NextLightActionEntity({this.action, this.time});

  @override
  List<Object?> get props => [action, time];
}

class TempHumDataEntity extends Equatable {
  final double? temperatureCelsius;
  final double? humidityPercentage;

  const TempHumDataEntity({this.temperatureCelsius, this.humidityPercentage});

  @override
  List<Object?> get props => [temperatureCelsius, humidityPercentage];
}

class NotificationSettingEntity extends Equatable {
  final bool? controllerStartup;
  final bool? lightSchedule;
  final bool? wateringStarted;
  final bool? wateringCompleted;
  final int? downtimeMs;

  const NotificationSettingEntity({
    this.controllerStartup,
    this.lightSchedule,
    this.wateringStarted,
    this.wateringCompleted,
    this.downtimeMs,
  });

  @override
  List<Object?> get props => [
    controllerStartup,
    lightSchedule,
    wateringStarted,
    wateringCompleted,
    downtimeMs,
  ];
}
