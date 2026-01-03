// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import '../../../zone/domain/entities/zone_entity.dart';

class WaterRoutineEntity extends Equatable {
  final String? id;
  final String? name;
  final List<StepEntity>? steps;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WaterRoutineEntity({
    this.id,
    this.name,
    this.steps,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props {
    return [id, name, steps, endDate, createdAt, updatedAt];
  }
}

class StepEntity extends Equatable {
  final ZoneEntity? zone;
  final int? durationMs;

  const StepEntity({this.zone, this.durationMs});

  @override
  List<Object?> get props => [zone, durationMs];

  StepEntity copyWith({ZoneEntity? zone, int? durationMs}) {
    return StepEntity(
      zone: zone ?? this.zone,
      durationMs: durationMs ?? this.durationMs,
    );
  }
}
