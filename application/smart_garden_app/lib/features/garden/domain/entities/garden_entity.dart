// Garden Entity
// Core business entity for garden

import 'package:equatable/equatable.dart';

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
