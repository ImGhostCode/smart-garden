// Zone Entity
// Core business entity for zone

import 'package:equatable/equatable.dart';

import '../../../garden/domain/entities/garden_entity.dart';
import '../../../water_schedule/domain/entities/water_schedule_entity.dart';

class ZoneEntity extends Equatable {
  final ZoneDetailEntity? details;
  final String? id;
  final GardenEntity? garden;
  final String? name;
  final int? position;
  final List<WaterScheduleEntity>? waterSchedules;
  final int? skipCount;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final WeatherDataEntity? weatherData;
  final NextWaterEntity? nextWater;

  const ZoneEntity({
    this.details,
    this.id,
    this.garden,
    this.name,
    this.position,
    this.waterSchedules,
    this.skipCount,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.weatherData,
    this.nextWater,
  });

  @override
  List<Object?> get props => [
    details,
    id,
    garden,
    name,
    position,
    waterSchedules,
    skipCount,
    endDate,
    createdAt,
    updatedAt,
    weatherData,
    nextWater,
  ];
}

class ZoneDetailEntity extends Equatable {
  final String? description;

  const ZoneDetailEntity({this.description});

  @override
  List<Object?> get props => [description];
}

class NextWaterEntity extends Equatable {
  final DateTime? time;
  final int? durationMs;
  final WaterScheduleEntity? waterSchedule;
  final String? message;

  const NextWaterEntity({
    this.time,
    this.durationMs,
    this.waterSchedule,
    this.message,
  });

  @override
  List<Object?> get props => [time, durationMs, waterSchedule, message];
}

class WeatherDataEntity extends Equatable {
  final RainEntity? rain;
  final TemperatureEntity? temperature;

  const WeatherDataEntity({this.rain, this.temperature});

  @override
  List<Object?> get props => [rain, temperature];
}

class RainEntity extends Equatable {
  final double? mm;
  final int? scaleFactor;

  const RainEntity({this.mm, this.scaleFactor});

  @override
  List<Object?> get props => [mm, scaleFactor];
}

class TemperatureEntity extends Equatable {
  final double? celsius;
  final double? scaleFactor;

  const TemperatureEntity({this.celsius, this.scaleFactor});

  @override
  List<Object?> get props => [celsius, scaleFactor];
}
