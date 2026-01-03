import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/water_schedule_entity.dart';
import '../../domain/usecases/get_all_water_schedules.dart';
import '../../domain/usecases/get_water_schedule_by_id.dart';
import '../../providers/water_schedule_providers.dart';

class WaterScheduleState {
  final bool isLoadingWSs;
  final List<WaterScheduleEntity> waterSchedules;
  final String? errLoadingWSs;

  final bool isLoadingWS;
  final WaterScheduleEntity? waterSchedule;
  final String? errLoadingWS;

  final bool isCreatingWS;
  final String? errCreatingWS;

  final bool isEditingWS;
  final String? errEditingWS;

  final String? responseMsg;

  const WaterScheduleState({
    this.isLoadingWSs = false,
    this.isLoadingWS = false,
    this.isCreatingWS = false,
    this.isEditingWS = false,
    this.waterSchedules = const [],
    this.waterSchedule,
    this.responseMsg,
    this.errLoadingWSs,
    this.errLoadingWS,
    this.errCreatingWS,
    this.errEditingWS,
  });

  WaterScheduleState copyWith({
    bool? isLoadingWSs,
    bool? isLoadingWS,
    bool? isCreatingWS,
    bool? isEditingWS,
    List<WaterScheduleEntity>? waterSchedules,
    WaterScheduleEntity? Function()? waterSchedule,
    String? responseMsg,
    String? errLoadingWSs,
    String? errLoadingWS,
    String? errCreatingWS,
    String? errEditingWS,
  }) {
    return WaterScheduleState(
      isLoadingWSs: isLoadingWSs ?? this.isLoadingWSs,
      isLoadingWS: isLoadingWS ?? this.isLoadingWS,
      isCreatingWS: isCreatingWS ?? this.isCreatingWS,
      isEditingWS: isEditingWS ?? this.isEditingWS,
      waterSchedules: waterSchedules ?? this.waterSchedules,
      waterSchedule: waterSchedule != null
          ? waterSchedule()
          : this.waterSchedule,
      errLoadingWSs: errLoadingWSs ?? this.errLoadingWSs,
      errLoadingWS: errLoadingWS ?? this.errLoadingWS,
      errCreatingWS: errCreatingWS ?? this.errCreatingWS,
      errEditingWS: errEditingWS ?? this.errEditingWS,
      responseMsg: responseMsg,
    );
  }
}

// Auth notifier
class WaterScheduleNotifier extends Notifier<WaterScheduleState> {
  @override
  WaterScheduleState build() {
    return const WaterScheduleState();
  }

  Future<void> getAllWaterSchedule(GetAllWSParams params) async {
    state = state.copyWith(
      isLoadingWSs: true,
      errLoadingWSs: null,
      waterSchedules: [],
    );

    final getAllWaterSchedules = ref.read(getAllWSUCProvider);
    final result = await getAllWaterSchedules.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingWSs: false,
        errLoadingWSs: failure.message,
      ),
      (waterSchedules) => state = state.copyWith(
        isLoadingWSs: false,
        waterSchedules: waterSchedules,
      ),
    );
  }

  Future<void> getWaterScheduleById({required String id}) async {
    state = state.copyWith(
      isLoadingWS: true,
      errLoadingWS: null,
      waterSchedule: () => null,
    );

    final getWaterScheduleById = ref.read(getWSByIdUCProvider);
    final result = await getWaterScheduleById.call(GetWSParams(id: id));

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingWS: false,
        errLoadingWS: failure.message,
      ),
      (waterSchedule) => state = state.copyWith(
        isLoadingWS: false,
        waterSchedule: () => waterSchedule,
      ),
    );
  }

  Future<void> createWaterSchedule(WaterScheduleEntity waterSchedule) async {
    state = state.copyWith(isCreatingWS: true, errCreatingWS: null);

    final newWaterSchedule = ref.read(newWaterScheduleUCProvider);
    final result = await newWaterSchedule.call(waterSchedule);

    result.fold(
      (failure) => state = state.copyWith(
        isCreatingWS: false,
        errCreatingWS: failure.message,
      ),
      (createdWS) => state = state.copyWith(
        isCreatingWS: false,
        responseMsg: 'Water Schedule created successfully',
      ),
    );
  }

  Future<void> editWaterSchedule(WaterScheduleEntity waterSchedule) async {
    state = state.copyWith(isEditingWS: true, errEditingWS: null);

    final editWaterSchedule = ref.read(editWaterScheduleUCProvider);
    final result = await editWaterSchedule.call(waterSchedule);

    result.fold(
      (failure) => state = state.copyWith(
        isEditingWS: false,
        errEditingWS: failure.message,
      ),
      (updatedWS) => state = state.copyWith(
        isEditingWS: false,
        responseMsg: 'Water Schedule updated successfully',
      ),
    );
  }
}

// Auth provider
final waterScheduleProvider =
    NotifierProvider<WaterScheduleNotifier, WaterScheduleState>(
      WaterScheduleNotifier.new,
    );
