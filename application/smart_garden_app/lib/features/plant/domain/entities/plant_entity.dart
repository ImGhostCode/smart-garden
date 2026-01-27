// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import '../../../garden/domain/entities/garden_entity.dart';
import '../../../zone/domain/entities/zone_entity.dart';

class PlantEntity extends Equatable {
  final String? name;
  final ZoneEntity? zone;
  final GardenEntity? garden;
  final PlantDetailEntity? details;
  final String? id;
  final DateTime? createdAt;
  final DateTime? endDate;
  final DateTime? nextWaterTime;

  const PlantEntity({
    this.name,
    this.zone,
    this.garden,
    this.details,
    this.id,
    this.createdAt,
    this.endDate,
    this.nextWaterTime,
  });

  @override
  List<Object?> get props {
    return [name, garden, zone, details, id, createdAt, endDate, nextWaterTime];
  }
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
