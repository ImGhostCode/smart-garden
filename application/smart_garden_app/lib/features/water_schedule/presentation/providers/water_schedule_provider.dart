import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/water_schedule_entity.dart';
import '../../domain/usecases/get_all_water_schedules.dart';
import '../../domain/usecases/get_water_schedule_by_id.dart';
import '../../providers/water_schedule_providers.dart';

class WaterScheduleState {
  final bool isLoadingWSs;
  final List<WaterScheduleEntity> waterSchedules;
  final String errLoadingWSs;

  final bool isLoadingWS;
  final WaterScheduleEntity? waterSchedule;
  final String errLoadingWS;

  final bool isCreatingWS;
  final String errCreatingWS;

  final bool isEditingWS;
  final String errEditingWS;

  final bool isDeletingWS;
  final String errDeletingWS;

  final String? responseMsg;

  const WaterScheduleState({
    this.isLoadingWSs = false,
    this.isLoadingWS = false,
    this.isCreatingWS = false,
    this.isEditingWS = false,
    this.isDeletingWS = false,
    this.waterSchedules = const [],
    this.waterSchedule,
    this.responseMsg,
    this.errLoadingWSs = '',
    this.errLoadingWS = '',
    this.errCreatingWS = '',
    this.errEditingWS = '',
    this.errDeletingWS = '',
  });

  WaterScheduleState copyWith({
    bool? isLoadingWSs,
    bool? isLoadingWS,
    bool? isCreatingWS,
    bool? isEditingWS,
    bool? isDeletingWS,
    List<WaterScheduleEntity>? waterSchedules,
    WaterScheduleEntity? Function()? waterSchedule,
    String? responseMsg,
    String? errLoadingWSs,
    String? errLoadingWS,
    String? errCreatingWS,
    String? errEditingWS,
    String? errDeletingWS,
  }) {
    return WaterScheduleState(
      isLoadingWSs: isLoadingWSs ?? this.isLoadingWSs,
      isLoadingWS: isLoadingWS ?? this.isLoadingWS,
      isCreatingWS: isCreatingWS ?? this.isCreatingWS,
      isEditingWS: isEditingWS ?? this.isEditingWS,
      isDeletingWS: isDeletingWS ?? this.isDeletingWS,
      waterSchedules: waterSchedules ?? this.waterSchedules,
      waterSchedule: waterSchedule != null
          ? waterSchedule()
          : this.waterSchedule,
      errLoadingWSs: errLoadingWSs ?? this.errLoadingWSs,
      errLoadingWS: errLoadingWS ?? this.errLoadingWS,
      errCreatingWS: errCreatingWS ?? this.errCreatingWS,
      errEditingWS: errEditingWS ?? this.errEditingWS,
      errDeletingWS: errDeletingWS ?? this.errDeletingWS,
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
      errLoadingWSs: '',
      waterSchedules: [],
    );

    final getAllWaterSchedules = ref.read(getAllWSUCProvider);
    final result = await getAllWaterSchedules.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingWSs: false,
        errLoadingWSs: failure.message,
      ),
      (response) => state = state.copyWith(
        isLoadingWSs: false,
        waterSchedules: response.data,
      ),
    );
  }

  Future<void> getWaterScheduleById({required String id}) async {
    state = state.copyWith(
      isLoadingWS: true,
      errLoadingWS: '',
      waterSchedule: () => null,
    );

    final getWaterScheduleById = ref.read(getWSByIdUCProvider);
    final result = await getWaterScheduleById.call(GetWSParams(id: id));

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingWS: false,
        errLoadingWS: failure.message,
      ),
      (response) => state = state.copyWith(
        isLoadingWS: false,
        waterSchedule: () => response.data,
      ),
    );
  }

  Future<void> createWaterSchedule(WaterScheduleEntity waterSchedule) async {
    state = state.copyWith(isCreatingWS: true, errCreatingWS: '');

    final newWaterSchedule = ref.read(newWaterScheduleUCProvider);
    final result = await newWaterSchedule.call(waterSchedule);

    result.fold(
      (failure) => state = state.copyWith(
        isCreatingWS: false,
        errCreatingWS: failure.message,
      ),
      (response) => state = state.copyWith(
        isCreatingWS: false,
        responseMsg: response.message,
      ),
    );
  }

  Future<void> editWaterSchedule(WaterScheduleEntity waterSchedule) async {
    state = state.copyWith(isEditingWS: true, errEditingWS: '');

    final editWaterSchedule = ref.read(editWaterScheduleUCProvider);
    final result = await editWaterSchedule.call(waterSchedule);

    result.fold(
      (failure) => state = state.copyWith(
        isEditingWS: false,
        errEditingWS: failure.message,
      ),
      (response) => state = state.copyWith(
        isEditingWS: false,
        responseMsg: response.message,
      ),
    );
  }

  Future<void> deleteWaterSchedule(String id) async {
    state = state.copyWith(isDeletingWS: true, errDeletingWS: '');

    final deleteWaterSchedule = ref.read(deleteWaterScheduleUCProvider);
    final result = await deleteWaterSchedule.call(id);

    result.fold(
      (failure) => state = state.copyWith(
        isDeletingWS: false,
        errDeletingWS: failure.message,
      ),
      (response) => state = state.copyWith(
        isDeletingWS: false,
        responseMsg: response.message,
      ),
    );
  }
}

// Auth provider
final waterScheduleProvider =
    NotifierProvider<WaterScheduleNotifier, WaterScheduleState>(
      WaterScheduleNotifier.new,
    );
