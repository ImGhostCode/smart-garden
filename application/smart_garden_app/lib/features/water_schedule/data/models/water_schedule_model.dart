import 'package:json_annotation/json_annotation.dart';

import '../../../zone/data/models/zone_model.dart';
import '../../domain/entities/water_schedule_entity.dart';

part 'water_schedule_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class WaterScheduleModel {
  final String? id;
  final String? name;
  final String? description;
  final int? durationMs;
  final int? interval;
  final String? startTime;
  final WeatherControlModel? weatherControl;
  final ActivePeriodModel? activePeriod;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // final List<Link>? links;
  final WeatherDataModel? weatherData;
  final NextWaterModel? nextWater;

  WaterScheduleModel({
    this.id,
    this.name,
    this.description,
    this.durationMs,
    this.interval,
    this.startTime,
    this.weatherControl,
    this.activePeriod,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    // this.links,
    this.weatherData,
    this.nextWater,
  });

  factory WaterScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$WaterScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$WaterScheduleModelToJson(this);

  WaterScheduleEntity toEntity() {
    return WaterScheduleEntity(
      id: id,
      name: name,
      description: description,
      durationMs: durationMs,
      interval: interval,
      startTime: startTime,
      weatherControl: weatherControl?.toEntity(),
      activePeriod: activePeriod,
      endDate: endDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      weatherData: weatherData?.toEntity(),
      nextWater: nextWater?.toEntity(),
    );
  }

  factory WaterScheduleModel.fromEntity(WaterScheduleEntity entity) {
    return WaterScheduleModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      durationMs: entity.durationMs,
      interval: entity.interval,
      startTime: entity.startTime,
      weatherControl: entity.weatherControl != null
          ? WeatherControlModel(
              rainControl: entity.weatherControl!.rainControl != null
                  ? ControlModel(
                      baselineValue:
                          entity.weatherControl!.rainControl!.baselineValue,
                      factor: entity.weatherControl!.rainControl!.factor,
                      range: entity.weatherControl!.rainControl!.range,
                      clientId: entity.weatherControl!.rainControl!.clientId,
                    )
                  : null,
              temperatureControl:
                  entity.weatherControl!.temperatureControl != null
                  ? ControlModel(
                      baselineValue: entity
                          .weatherControl!
                          .temperatureControl!
                          .baselineValue,
                      factor: entity.weatherControl!.temperatureControl!.factor,
                      range: entity.weatherControl!.temperatureControl!.range,
                      clientId:
                          entity.weatherControl!.temperatureControl!.clientId,
                    )
                  : null,
            )
          : null,
      activePeriod: entity.activePeriod != null
          ? ActivePeriodModel(
              startMonth: entity.activePeriod!.startMonth,
              endMonth: entity.activePeriod!.endMonth,
            )
          : null,
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

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class WeatherControlModel {
  final ControlModel? rainControl;
  final ControlModel? temperatureControl;

  WeatherControlModel({this.rainControl, this.temperatureControl});

  factory WeatherControlModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherControlModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherControlModelToJson(this);

  WeatherControlEntity toEntity() {
    return WeatherControlEntity(
      rainControl: rainControl,
      temperatureControl: temperatureControl,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ActivePeriodModel extends ActivePeriodEntity {
  const ActivePeriodModel({super.startMonth, super.endMonth});

  factory ActivePeriodModel.fromJson(Map<String, dynamic> json) =>
      _$ActivePeriodModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActivePeriodModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ControlModel extends ControlEntity {
  const ControlModel({
    super.baselineValue,
    super.factor,
    super.range,
    super.clientId,
  });

  factory ControlModel.fromJson(Map<String, dynamic> json) =>
      _$ControlModelFromJson(json);

  Map<String, dynamic> toJson() => _$ControlModelToJson(this);
}
