import 'package:json_annotation/json_annotation.dart';

import '../../../garden/data/models/garden_model.dart';
import '../../../water_schedule/data/models/water_schedule_model.dart';
import '../../domain/entities/zone_entity.dart';

part 'zone_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ZoneModel {
  final ZoneDetailModel? details;
  final String? id;
  final GardenModel? garden;
  final String? name;
  final int? position;
  final List<WaterScheduleModel>? waterSchedules;
  final int? skipCount;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final WeatherDataModel? weatherData;
  final NextWaterModel? nextWater;

  ZoneModel({
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

  factory ZoneModel.fromJson(Map<String, dynamic> json) =>
      _$ZoneModelFromJson(json);

  Map<String, dynamic> toJson() => _$ZoneModelToJson(this);

  ZoneEntity toEntity() {
    return ZoneEntity(
      details: details,
      id: id,
      garden: garden?.toEntity(),
      name: name,
      position: position,
      waterSchedules: waterSchedules?.map((e) => e.toEntity()).toList(),
      skipCount: skipCount,
      endDate: endDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      weatherData: weatherData?.toEntity(),
      nextWater: nextWater?.toEntity(),
    );
  }

  static ZoneModel fromEntity(ZoneEntity entity) {
    return ZoneModel(
      details: entity.details != null
          ? ZoneDetailModel.fromEntity(entity.details!)
          : null,
      id: entity.id,
      garden: entity.garden != null
          ? GardenModel.fromEntity(entity.garden!)
          : null,
      name: entity.name,
      position: entity.position,
      waterSchedules: entity.waterSchedules
          ?.map((wsEntity) => WaterScheduleModel.fromEntity(wsEntity))
          .toList(),
      skipCount: entity.skipCount,
      endDate: entity.endDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      weatherData: entity.weatherData != null
          ? WeatherDataModel.fromEntity(entity.weatherData!)
          : null,
      nextWater: entity.nextWater != null
          ? NextWaterModel.fromEntity(entity.nextWater!)
          : null,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ZoneDetailModel extends ZoneDetailEntity {
  const ZoneDetailModel({super.description, super.notes});

  factory ZoneDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ZoneDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$ZoneDetailModelToJson(this);

  static ZoneDetailModel fromEntity(ZoneDetailEntity entity) {
    return ZoneDetailModel(
      description: entity.description,
      notes: entity.notes,
    );
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class NextWaterModel {
  final DateTime? time;
  final int? durationMs;
  final WaterScheduleModel? waterSchedule;
  final String? message;
  const NextWaterModel({
    this.time,
    this.durationMs,
    this.waterSchedule,
    this.message,
  });

  factory NextWaterModel.fromJson(Map<String, dynamic> json) =>
      _$NextWaterModelFromJson(json);

  Map<String, dynamic> toJson() => _$NextWaterModelToJson(this);

  NextWaterEntity toEntity() {
    return NextWaterEntity(
      time: time,
      durationMs: durationMs,
      waterSchedule: waterSchedule?.toEntity(),
      message: message,
    );
  }

  factory NextWaterModel.fromEntity(NextWaterEntity entity) {
    return NextWaterModel(
      time: entity.time,
      durationMs: entity.durationMs,
      waterSchedule: entity.waterSchedule != null
          ? WaterScheduleModel.fromEntity(entity.waterSchedule!)
          : null,
      message: entity.message,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class WeatherDataModel {
  final RainModel? rain;
  final TemperatureModel? temperature;

  WeatherDataModel({this.rain, this.temperature});

  factory WeatherDataModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherDataModelToJson(this);

  WeatherDataEntity toEntity() {
    return WeatherDataEntity(rain: rain, temperature: temperature);
  }

  factory WeatherDataModel.fromEntity(WeatherDataEntity entity) {
    return WeatherDataModel(
      rain: entity.rain != null
          ? RainModel(
              mm: entity.rain!.mm,
              scaleFactor: entity.rain!.scaleFactor,
            )
          : null,
      temperature: entity.temperature != null
          ? TemperatureModel(
              celsius: entity.temperature!.celsius,
              scaleFactor: entity.temperature!.scaleFactor,
            )
          : null,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RainModel extends RainEntity {
  const RainModel({super.mm, super.scaleFactor});

  factory RainModel.fromJson(Map<String, dynamic> json) =>
      _$RainModelFromJson(json);

  Map<String, dynamic> toJson() => _$RainModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TemperatureModel extends TemperatureEntity {
  const TemperatureModel({super.celsius, super.scaleFactor});

  factory TemperatureModel.fromJson(Map<String, dynamic> json) =>
      _$TemperatureModelFromJson(json);

  Map<String, dynamic> toJson() => _$TemperatureModelToJson(this);
}
