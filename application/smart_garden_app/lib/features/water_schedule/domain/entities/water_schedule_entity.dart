// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import '../../../notification_client/domain/entities/notification_client_entity.dart';
import '../../../zone/domain/entities/zone_entity.dart';

class WaterScheduleEntity extends Equatable {
  final String? id;
  final String? name;
  final String? description;
  final int? durationMs;
  final int? interval;
  final String? startTime;
  final WeatherControlEntity? weatherControl;
  final ActivePeriodEntity? activePeriod;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // final List<Link>? links;
  final WeatherDataEntity? weatherData;
  final NextWaterEntity? nextWater;
  final NotificationClientEntity? notificationClient;

  const WaterScheduleEntity({
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
    this.notificationClient,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    durationMs,
    interval,
    startTime,
    weatherControl,
    activePeriod,
    endDate,
    createdAt,
    updatedAt,
    weatherData,
    nextWater,
    notificationClient,
  ];
}

// class Link {
//     final String? rel;
//     final String? href;

//     Link({
//         this.rel,
//         this.href,
//     });

// }

class WeatherControlEntity extends Equatable {
  final ControlEntity? rainControl;
  final ControlEntity? temperatureControl;

  const WeatherControlEntity({this.rainControl, this.temperatureControl});

  @override
  List<Object?> get props => [rainControl, temperatureControl];
}

class ActivePeriodEntity extends Equatable {
  final String? startMonth;
  final String? endMonth;

  const ActivePeriodEntity({this.startMonth, this.endMonth});

  @override
  List<Object?> get props => [startMonth, endMonth];
}

class ControlEntity extends Equatable {
  final double? baselineValue;
  final double? factor;
  final double? range;
  final String? clientId;

  const ControlEntity({
    this.baselineValue,
    this.factor,
    this.range,
    this.clientId,
  });

  @override
  List<Object?> get props => [baselineValue, factor, range, clientId];
}
