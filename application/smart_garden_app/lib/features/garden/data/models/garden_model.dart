import 'package:json_annotation/json_annotation.dart';

import '../../../notification_client/data/models/notification_client_model.dart';
import '../../domain/entities/garden_entity.dart';

part 'garden_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class GardenModel {
  final String? id;
  final String? name;
  final String? topicPrefix;
  final int? maxZones;
  final LightScheduleModel? lightSchedule;
  final DateTime? endDate;
  final ControllerConfigModel? controllerConfig;
  final NextLightActionModel? nextLightAction;
  final HealthModel? health;
  @JsonKey(name: 'temperature_humidity_data')
  final TempHumDataModel? tempHumData;
  final int? numPlants;
  final int? numZones;
  final NotificationClientModel? notificationClient;
  final NotificationSettingModel? notificationSettings;

  const GardenModel({
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

  factory GardenModel.fromJson(Map<String, dynamic> json) =>
      _$GardenModelFromJson(json);
  Map<String, dynamic> toJson() => _$GardenModelToJson(this);

  GardenEntity toEntity() {
    return GardenEntity(
      id: id,
      name: name,
      topicPrefix: topicPrefix,
      maxZones: maxZones,
      endDate: endDate,
      numPlants: numPlants,
      numZones: numZones,
      lightSchedule: lightSchedule,
      controllerConfig: controllerConfig,
      nextLightAction: nextLightAction,
      health: health,
      tempHumData: tempHumData,
      notificationClient: notificationClient?.toEntity(),
      notificationSettings: notificationSettings,
    );
  }

  static GardenModel fromEntity(GardenEntity garden) {
    return GardenModel(
      id: garden.id,
      name: garden.name,
      topicPrefix: garden.topicPrefix,
      maxZones: garden.maxZones,
      endDate: garden.endDate,
      numPlants: garden.numPlants,
      numZones: garden.numZones,
      lightSchedule: garden.lightSchedule != null
          ? LightScheduleModel(
              durationMs: garden.lightSchedule!.durationMs,
              startTime: garden.lightSchedule!.startTime,
            )
          : null,
      controllerConfig: garden.controllerConfig != null
          ? ControllerConfigModel(
              valvePins: garden.controllerConfig!.valvePins,
              pumpPins: garden.controllerConfig!.pumpPins,
              lightPin: garden.controllerConfig!.lightPin,
              tempHumidityPin: garden.controllerConfig!.tempHumidityPin,
              tempHumIntervalMs: garden.controllerConfig!.tempHumIntervalMs,
            )
          : null,
      nextLightAction: garden.nextLightAction != null
          ? NextLightActionModel(
              action: garden.nextLightAction!.action,
              time: garden.nextLightAction!.time,
            )
          : null,
      health: garden.health != null
          ? HealthModel(
              status: garden.health!.status,
              details: garden.health!.details,
              lastContact: garden.health!.lastContact,
            )
          : null,
      tempHumData: garden.tempHumData != null
          ? TempHumDataModel(
              temperatureCelsius: garden.tempHumData!.temperatureCelsius,
              humidityPercentage: garden.tempHumData!.humidityPercentage,
            )
          : null,
      notificationClient: garden.notificationClient != null
          ? NotificationClientModel.fromEntity(garden.notificationClient!)
          : null,
      notificationSettings: garden.notificationSettings != null
          ? NotificationSettingModel(
              controllerStartup: garden.notificationSettings!.controllerStartup,
              lightSchedule: garden.notificationSettings!.lightSchedule,
              wateringStarted: garden.notificationSettings!.wateringStarted,
              wateringCompleted: garden.notificationSettings!.wateringCompleted,
              downtimeMs: garden.notificationSettings!.downtimeMs,
            )
          : null,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ControllerConfigModel extends ControllerConfigEntity {
  const ControllerConfigModel({
    super.valvePins,
    super.pumpPins,
    super.lightPin,
    super.tempHumidityPin,
    super.tempHumIntervalMs,
  });

  factory ControllerConfigModel.fromJson(Map<String, dynamic> json) =>
      _$ControllerConfigModelFromJson(json);
  Map<String, dynamic> toJson() => _$ControllerConfigModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class HealthModel extends HealthEntity {
  const HealthModel({super.status, super.details, super.lastContact});

  factory HealthModel.fromJson(Map<String, dynamic> json) =>
      _$HealthModelFromJson(json);
  Map<String, dynamic> toJson() => _$HealthModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LightScheduleModel extends LightScheduleEntity {
  const LightScheduleModel({super.durationMs, super.startTime});

  factory LightScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$LightScheduleModelFromJson(json);
  Map<String, dynamic> toJson() => _$LightScheduleModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class NextLightActionModel extends NextLightActionEntity {
  const NextLightActionModel({super.action, super.time});

  factory NextLightActionModel.fromJson(Map<String, dynamic> json) =>
      _$NextLightActionModelFromJson(json);
  Map<String, dynamic> toJson() => _$NextLightActionModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TempHumDataModel extends TempHumDataEntity {
  const TempHumDataModel({super.temperatureCelsius, super.humidityPercentage});

  factory TempHumDataModel.fromJson(Map<String, dynamic> json) =>
      _$TempHumDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$TempHumDataModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class NotificationSettingModel extends NotificationSettingEntity {
  const NotificationSettingModel({
    super.controllerStartup,
    super.lightSchedule,
    super.wateringStarted,
    super.wateringCompleted,
    super.downtimeMs,
  });

  factory NotificationSettingModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationSettingModelToJson(this);
}
