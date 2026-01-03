import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/water_history_entity.dart';

part 'water_history_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class WaterHistoryModel extends WaterHistoryEntity {
  const WaterHistoryModel({
    super.eventId,
    super.zoneId,
    super.status,
    super.source,
    super.durationMs,
    super.sentAt,
    super.completedAt,
    super.startedAt,
    super.recordTime,
  });

  factory WaterHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$WaterHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$WaterHistoryModelToJson(this);

  WaterHistoryEntity toEntity() {
    return WaterHistoryEntity(
      eventId: eventId,
      zoneId: zoneId,
      status: status,
      source: source,
      durationMs: durationMs,
      sentAt: sentAt,
      completedAt: completedAt,
      startedAt: startedAt,
      recordTime: recordTime,
    );
  }
}
