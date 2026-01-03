import 'package:json_annotation/json_annotation.dart';

import '../../../zone/data/models/zone_model.dart';
import '../../domain/entities/water_routine_entity.dart';

part 'water_routine_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class WaterRoutineModel {
  final String? id;
  final String? name;
  final List<StepModel>? steps;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WaterRoutineModel({
    this.id,
    this.name,
    this.steps,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory WaterRoutineModel.fromJson(Map<String, dynamic> json) =>
      _$WaterRoutineModelFromJson(json);

  Map<String, dynamic> toJson() => _$WaterRoutineModelToJson(this);

  WaterRoutineEntity toEntity() {
    return WaterRoutineEntity(
      id: id,
      name: name,
      steps: steps?.map((step) => step.toEntity()).toList(),
      endDate: endDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static WaterRoutineModel fromEntity(WaterRoutineEntity entity) {
    return WaterRoutineModel(
      id: entity.id,
      name: entity.name,
      steps: entity.steps
          ?.map(
            (stepEntity) => StepModel(
              zone: stepEntity.zone != null
                  ? ZoneModel.fromEntity(stepEntity.zone!)
                  : null,
              durationMs: stepEntity.durationMs,
            ),
          )
          .toList(),
      endDate: entity.endDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class StepModel {
  final ZoneModel? zone;
  final int? durationMs;
  const StepModel({this.zone, this.durationMs});

  factory StepModel.fromJson(Map<String, dynamic> json) =>
      _$StepModelFromJson(json);

  Map<String, dynamic> toJson() => _$StepModelToJson(this);

  StepEntity toEntity() {
    return StepEntity(zone: zone?.toEntity(), durationMs: durationMs);
  }
}
