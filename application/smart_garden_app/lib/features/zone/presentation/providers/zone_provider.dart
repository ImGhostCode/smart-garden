import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/water_history_entity.dart';
import '../../domain/entities/zone_entity.dart';
import '../../domain/usecases/get_all_zones.dart';
import '../../domain/usecases/get_water_history.dart';
import '../../domain/usecases/get_zone_by_id.dart';
import '../../providers/zone_providers.dart';

class ZoneState {
  final bool isLoadingZones;
  final List<ZoneEntity> zones;
  final String? errLoadingZones;

  final bool isLoadingZone;
  final ZoneEntity? zone;
  final String? errLoadingZone;

  final bool isLoadingWHistory;
  final List<WaterHistoryEntity> waterHistory;
  final String? errLoadingWHistory;

  final String? responseMsg;

  const ZoneState({
    this.isLoadingZones = false,
    this.isLoadingZone = false,
    this.isLoadingWHistory = false,
    this.zones = const [],
    this.zone,
    this.waterHistory = const [],
    this.responseMsg,
    this.errLoadingZones,
    this.errLoadingZone,
    this.errLoadingWHistory,
  });

  ZoneState copyWith({
    bool? isLoadingZones,
    bool? isLoadingZone,
    bool? isLoadingWHistory,
    List<ZoneEntity>? zones,
    ZoneEntity? Function()? zone,
    List<WaterHistoryEntity>? waterHistory,
    String? responseMsg,
    String? errLoadingZones,
    String? errLoadingZone,
    String? errLoadingWHistory,
  }) {
    return ZoneState(
      isLoadingZones: isLoadingZones ?? this.isLoadingZones,
      isLoadingZone: isLoadingZone ?? this.isLoadingZone,
      isLoadingWHistory: isLoadingWHistory ?? this.isLoadingWHistory,
      zones: zones ?? this.zones,
      zone: zone != null ? zone() : this.zone,
      waterHistory: waterHistory ?? this.waterHistory,
      errLoadingZones: errLoadingZones ?? this.errLoadingZones,
      errLoadingZone: errLoadingZone ?? this.errLoadingZone,
      errLoadingWHistory: errLoadingWHistory ?? this.errLoadingWHistory,
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
      errLoadingZones: null,
      zones: [],
    );

    final getAllZones = ref.read(getAllZoneUCProvider);
    final result = await getAllZones.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingZones: false,
        errLoadingZones: failure.message,
      ),
      (zones) => state = state.copyWith(isLoadingZones: false, zones: zones),
    );
  }

  Future<void> getZoneById({required String id}) async {
    state = state.copyWith(
      isLoadingZone: true,
      errLoadingZone: null,
      zone: () => null,
    );

    final getZoneById = ref.read(getZoneByIdUCProvider);
    final result = await getZoneById.call(ZoneParams(id: id));

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingZone: false,
        errLoadingZone: failure.message,
      ),
      (zone) => state = state.copyWith(isLoadingZone: false, zone: () => zone),
    );
  }

  Future<void> getWaterHistory(GetWaterHistoryParams params) async {
    state = state.copyWith(
      isLoadingWHistory: true,
      errLoadingWHistory: null,
      waterHistory: null,
    );

    final getWaterHistory = ref.read(getWaterHistoryUCProvider);
    final result = await getWaterHistory.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingWHistory: false,
        errLoadingWHistory: failure.message,
      ),
      (waterHistory) => state = state.copyWith(
        isLoadingWHistory: false,
        waterHistory: waterHistory,
      ),
    );
  }

  void clearZones() {
    state = state.copyWith(zones: []);
  }
}

// Auth provider
final zoneProvider = NotifierProvider<ZoneNotifier, ZoneState>(
  ZoneNotifier.new,
);
