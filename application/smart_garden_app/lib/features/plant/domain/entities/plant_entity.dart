// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import '../../../zone/domain/entities/zone_entity.dart';

class PlantEntity {
  final String? name;
  final ZoneEntity? zone;
  final PlantDetailEntity? details;
  final String? id;
  final DateTime? createdAt;
  final DateTime? endDate;
  final DateTime? nextWaterTime;

  PlantEntity({
    this.name,
    this.zone,
    this.details,
    this.id,
    this.createdAt,
    this.endDate,
    this.nextWaterTime,
  });
}

class PlantDetailEntity extends Equatable {
  final String? description;
  final String? notes;
  final String? timeToHarvest;
  final int? count;

  const PlantDetailEntity({
    this.description,
    this.notes,
    this.timeToHarvest,
    this.count,
  });

  @override
  List<Object?> get props => [description, notes, timeToHarvest, count];
}
