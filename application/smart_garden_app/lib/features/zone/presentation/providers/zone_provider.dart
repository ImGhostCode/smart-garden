import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/water_history_entity.dart';
import '../../domain/entities/zone_entity.dart';
import '../../domain/usecases/delete_zone.dart';
import '../../domain/usecases/edit_zone.dart';
import '../../domain/usecases/get_all_zones.dart';
import '../../domain/usecases/get_water_history.dart';
import '../../domain/usecases/get_zone_by_id.dart';
import '../../domain/usecases/new_zone.dart';
import '../../domain/usecases/send_zone_action.dart';
import '../../providers/zone_providers.dart';

class ZoneState {
  final bool isLoadingZones;
  final List<ZoneEntity> zones;
  final String errLoadingZones;

  final bool isLoadingZone;
  final ZoneEntity? zone;
  final String errLoadingZone;

  final bool isLoadingWHistory;
  final List<WaterHistoryEntity> waterHistory;
  final String errLoadingWHistory;

  final bool isCreatingZone;
  final String errCreatingZone;

  final bool isEditingZone;
  final String errEditingZone;

  final bool isDeletingZone;
  final String errDeletingZone;

  final bool isSendingAction;
  final String errSendingAction;

  final String? responseMsg;

  const ZoneState({
    this.isLoadingZones = false,
    this.isLoadingZone = false,
    this.isLoadingWHistory = false,
    this.isCreatingZone = false,
    this.isEditingZone = false,
    this.isDeletingZone = false,
    this.isSendingAction = false,
    this.zones = const [],
    this.zone,
    this.waterHistory = const [],
    this.responseMsg,
    this.errLoadingZones = "",
    this.errLoadingZone = "",
    this.errLoadingWHistory = "",
    this.errCreatingZone = "",
    this.errEditingZone = "",
    this.errDeletingZone = "",
    this.errSendingAction = "",
  });

  ZoneState copyWith({
    bool? isLoadingZones,
    bool? isLoadingZone,
    bool? isLoadingWHistory,
    bool? isCreatingZone,
    bool? isEditingZone,
    bool? isDeletingZone,
    bool? isSendingAction,
    List<ZoneEntity>? zones,
    ZoneEntity? Function()? zone,
    List<WaterHistoryEntity>? waterHistory,
    String? responseMsg,
    String? errLoadingZones,
    String? errLoadingZone,
    String? errLoadingWHistory,
    String? errCreatingZone,
    String? errEditingZone,
    String? errDeletingZone,
    String? errSendingAction,
  }) {
    return ZoneState(
      isLoadingZones: isLoadingZones ?? this.isLoadingZones,
      isLoadingZone: isLoadingZone ?? this.isLoadingZone,
      isLoadingWHistory: isLoadingWHistory ?? this.isLoadingWHistory,
      isCreatingZone: isCreatingZone ?? this.isCreatingZone,
      isEditingZone: isEditingZone ?? this.isEditingZone,
      isDeletingZone: isDeletingZone ?? this.isDeletingZone,
      isSendingAction: isSendingAction ?? this.isSendingAction,
      zones: zones ?? this.zones,
      zone: zone != null ? zone() : this.zone,
      waterHistory: waterHistory ?? this.waterHistory,
      errLoadingZones: errLoadingZones ?? this.errLoadingZones,
      errLoadingZone: errLoadingZone ?? this.errLoadingZone,
      errLoadingWHistory: errLoadingWHistory ?? this.errLoadingWHistory,
      errCreatingZone: errCreatingZone ?? this.errCreatingZone,
      errEditingZone: errEditingZone ?? this.errEditingZone,
      errDeletingZone: errDeletingZone ?? this.errDeletingZone,
      errSendingAction: errSendingAction ?? this.errSendingAction,
      responseMsg: responseMsg,
    );
  }
}

// Auth notifier
class ZoneNotifier extends Notifier<ZoneState> {
  @override
  ZoneState build() {
    return const ZoneState();
  }

  Future<void> getAllZone(GetAllZoneParams params) async {
    state = state.copyWith(
      isLoadingZones: true,
      errLoadingZones: "",
      zones: [],
    );

    final getAllZones = ref.read(getAllZoneUCProvider);
    final result = await getAllZones.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingZones: false,
        errLoadingZones: failure.message,
      ),
      (response) =>
          state = state.copyWith(isLoadingZones: false, zones: response.data),
    );
  }

  Future<void> getZoneById(GetZoneParams params) async {
    state = state.copyWith(
      isLoadingZone: true,
      errLoadingZone: "",
      zone: () => null,
    );

    final getZoneById = ref.read(getZoneByIdUCProvider);
    final result = await getZoneById.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingZone: false,
        errLoadingZone: failure.message,
      ),
      (response) => state = state.copyWith(
        isLoadingZone: false,
        zone: () => response.data,
      ),
    );
  }

  Future<void> getWaterHistory(GetWaterHistoryParams params) async {
    state = state.copyWith(
      isLoadingWHistory: true,
      errLoadingWHistory: "",
      waterHistory: [],
    );

    final getWaterHistory = ref.read(getWaterHistoryUCProvider);
    final result = await getWaterHistory.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingWHistory: false,
        errLoadingWHistory: failure.message,
      ),
      (response) => state = state.copyWith(
        isLoadingWHistory: false,
        waterHistory: response.data,
      ),
    );
  }

  Future<void> addZone(NewZoneParams params) async {
    state = state.copyWith(isCreatingZone: true, errCreatingZone: "");

    final newZone = ref.read(newZoneUCProvider);
    final result = await newZone.call(params);
    result.fold(
      (failure) => state = state.copyWith(
        isCreatingZone: false,
        errCreatingZone: failure.message,
      ),
      (response) => state = state.copyWith(
        isCreatingZone: false,
        zone: () => response.data,
        responseMsg: response.message,
      ),
    );
  }

  Future<void> editZone(EditZoneParams params) async {
    state = state.copyWith(isEditingZone: true, errEditingZone: "");

    final editZone = ref.read(editZoneUCProvider);
    final result = await editZone.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isEditingZone: false,
        errEditingZone: failure.message,
      ),
      (response) => state = state.copyWith(
        isEditingZone: false,
        zone: () => response.data,
        responseMsg: response.message,
      ),
    );
  }

  Future<void> deleteZone(DeleteZoneParams params) async {
    state = state.copyWith(isDeletingZone: true, errDeletingZone: "");

    final deleteZone = ref.read(deleteZoneUCProvider);
    final result = await deleteZone.call(params);
    result.fold(
      (failure) => state = state.copyWith(
        isDeletingZone: false,
        errDeletingZone: failure.message,
      ),
      (response) => state = state.copyWith(
        isDeletingZone: false,
        responseMsg: response.message,
      ),
    );
  }

  Future<void> sendZoneAction(ZoneActionParams params) async {
    state = state.copyWith(isSendingAction: true, errSendingAction: "");

    final sendZoneAction = ref.read(sendZoneActionUCProvider);
    final result = await sendZoneAction.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isSendingAction: false,
        errSendingAction: failure.message,
      ),
      (response) => state = state.copyWith(
        isSendingAction: false,
        responseMsg: response.message,
      ),
    );
  }

  void clearZones() {
    state = state.copyWith(zones: []);
  }

  List<int> existedPositions(String? gardenId) {
    if (gardenId == null) return [];
    return state.zones
        .where((zone) => zone.garden?.id == gardenId)
        .map((zone) => zone.position ?? -1)
        .toList();
  }
}

// Auth provider
final zoneProvider = NotifierProvider<ZoneNotifier, ZoneState>(
  ZoneNotifier.new,
);
