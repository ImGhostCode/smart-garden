// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class NotificationClientEntity extends Equatable {
  final String? id;
  final String? name;
  final String? type;
  final OptionEntity? options;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NotificationClientEntity({
    this.id,
    this.name,
    this.type,
    this.options,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props {
    return [id, name, type, options, endDate, createdAt, updatedAt];
  }

  NotificationClientEntity copyWith({
    String? id,
    String? name,
    String? type,
    OptionEntity? options,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationClientEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      options: options ?? this.options,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class OptionEntity extends Equatable {
  final String? user;
  final String? token;
  final String? deviceName;
  final String? createError;
  final String? sendMessageError;

  const OptionEntity({
    this.user,
    this.token,
    this.deviceName,
    this.createError,
    this.sendMessageError,
  });

  @override
  List<Object?> get props {
    return [user, token, deviceName, createError, sendMessageError];
  }
}
