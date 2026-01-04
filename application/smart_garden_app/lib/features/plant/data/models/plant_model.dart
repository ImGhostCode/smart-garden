import 'package:json_annotation/json_annotation.dart';

import '../../../zone/data/models/zone_model.dart';
import '../../domain/entities/plant_entity.dart';

part 'plant_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class PlantModel {
  final String? name;
  final ZoneModel? zone;
  final PlantDetailModel? details;
  final String? id;
  final DateTime? createdAt;
  final DateTime? endDate;
  final DateTime? nextWaterTime;

  PlantModel({
    this.name,
    this.zone,
    this.details,
    this.id,
    this.createdAt,
    this.endDate,
    this.nextWaterTime,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) =>
      _$PlantModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlantModelToJson(this);

  PlantEntity toEntity() {
    return PlantEntity(
      name: name,
      zone: zone?.toEntity(),
      details: details,
      id: id,
      createdAt: createdAt,
      endDate: endDate,
      nextWaterTime: nextWaterTime,
    );
  }

  static PlantModel fromEntity(PlantEntity entity) {
    return PlantModel(
      name: entity.name,
      zone: entity.zone != null ? ZoneModel.fromEntity(entity.zone!) : null,
      details: entity.details != null
          ? PlantDetailModel(
              description: entity.details!.description,
              notes: entity.details!.notes,
              timeToHarvest: entity.details!.timeToHarvest,
              count: entity.details!.count,
            )
          : null,
      id: entity.id,
      createdAt: entity.createdAt,
      endDate: entity.endDate,
      nextWaterTime: entity.nextWaterTime,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PlantDetailModel extends PlantDetailEntity {
  const PlantDetailModel({
    super.description,
    super.notes,
    super.timeToHarvest,
    super.count,
  });

  factory PlantDetailModel.fromJson(Map<String, dynamic> json) =>
      _$PlantDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlantDetailModelToJson(this);
}
