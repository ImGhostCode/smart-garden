// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class WaterHistoryEntity extends Equatable {
  final String? eventId;
  final String? zoneId;
  final String? status;
  final String? source;
  final int? durationMs;
  final DateTime? sentAt;
  final DateTime? completedAt;
  final DateTime? startedAt;
  final DateTime? recordTime;

  const WaterHistoryEntity({
    this.eventId,
    this.zoneId,
    this.status,
    this.source,
    this.durationMs,
    this.sentAt,
    this.completedAt,
    this.startedAt,
    this.recordTime,
  });

  @override
  List<Object?> get props {
    return [
      eventId,
      zoneId,
      status,
      source,
      durationMs,
      sentAt,
      completedAt,
      startedAt,
      recordTime,
    ];
  }
}
