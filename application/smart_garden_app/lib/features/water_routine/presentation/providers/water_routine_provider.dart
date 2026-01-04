import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/water_routine_entity.dart';
import '../../domain/usecases/get_all_water_routines.dart';
import '../../domain/usecases/get_water_routine_by_id.dart';
import '../../providers/water_routine_providers.dart';

class WaterRoutineState {
  final bool isLoadingWRs;
  final List<WaterRoutineEntity> waterRoutines;
  final String errLoadingWRs;

  final bool isLoadingWR;
  final WaterRoutineEntity? waterRoutine;
  final String errLoadingWR;

  final bool isCreatingWR;
  final String errCreatingWR;

  final bool isEditingWR;
  final String errEditingWR;

  final bool isDeletingWR;
  final String errDeletingWR;

  final bool isRunningWR;
  final String errRunningWR;

  final String? responseMsg;

  const WaterRoutineState({
    this.isLoadingWRs = false,
    this.isLoadingWR = false,
    this.isCreatingWR = false,
    this.isEditingWR = false,
    this.isDeletingWR = false,
    this.isRunningWR = false,
    this.waterRoutines = const [],
    this.waterRoutine,
    this.responseMsg,
    this.errLoadingWRs = '',
    this.errLoadingWR = '',
    this.errCreatingWR = '',
    this.errEditingWR = '',
    this.errDeletingWR = '',
    this.errRunningWR = '',
  });

  WaterRoutineState copyWith({
    bool? isLoadingWRs,
    bool? isLoadingWR,
    bool? isCreatingWR,
    bool? isEditingWR,
    bool? isDeletingWR,
    bool? isRunningWR,
    List<WaterRoutineEntity>? waterRoutines,
    WaterRoutineEntity? Function()? waterRoutine,
    String? responseMsg,
    String? errLoadingWRs,
    String? errLoadingWR,
    String? errCreatingWR,
    String? errEditingWR,
    String? errDeletingWR,
    String? errRunningWR,
  }) {
    return WaterRoutineState(
      isLoadingWRs: isLoadingWRs ?? this.isLoadingWRs,
      isLoadingWR: isLoadingWR ?? this.isLoadingWR,
      isCreatingWR: isCreatingWR ?? this.isCreatingWR,
      isEditingWR: isEditingWR ?? this.isEditingWR,
      isDeletingWR: isDeletingWR ?? this.isDeletingWR,
      isRunningWR: isRunningWR ?? this.isRunningWR,
      waterRoutines: waterRoutines ?? this.waterRoutines,
      waterRoutine: waterRoutine != null ? waterRoutine() : this.waterRoutine,
      errLoadingWRs: errLoadingWRs ?? this.errLoadingWRs,
      errLoadingWR: errLoadingWR ?? this.errLoadingWR,
      errCreatingWR: errCreatingWR ?? this.errCreatingWR,
      errEditingWR: errEditingWR ?? this.errEditingWR,
      errDeletingWR: errDeletingWR ?? this.errDeletingWR,
      errRunningWR: errRunningWR ?? this.errRunningWR,
      responseMsg: responseMsg,
    );
  }
}

// Auth notifier
class WaterRoutineNotifier extends Notifier<WaterRoutineState> {
  @override
  WaterRoutineState build() {
    return const WaterRoutineState();
  }

  Future<void> getAllWaterRoutine(GetAllWRParams params) async {
    state = state.copyWith(
      isLoadingWRs: true,
      errLoadingWRs: '',
      waterRoutines: [],
    );

    final getAllWaterRoutines = ref.read(getAllWRUCProvider);
    final result = await getAllWaterRoutines.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingWRs: false,
        errLoadingWRs: failure.message,
      ),
      (response) => state = state.copyWith(
        isLoadingWRs: false,
        waterRoutines: response.data,
      ),
    );
  }

  Future<void> getWaterRoutineById(GetWRParams params) async {
    state = state.copyWith(
      isLoadingWR: true,
      errLoadingWR: '',
      waterRoutine: () => null,
    );

    final getWaterRoutineById = ref.read(getWRByIdUCProvider);
    final result = await getWaterRoutineById.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingWR: false,
        errLoadingWR: failure.message,
      ),
      (response) => state = state.copyWith(
        isLoadingWR: false,
        waterRoutine: () => response.data,
      ),
    );
  }

  Future<void> newWaterRoutine(WaterRoutineEntity params) async {
    state = state.copyWith(isCreatingWR: true, errCreatingWR: '');

    final newWaterRoutine = ref.read(newWaterRoutineUCProvider);
    final result = await newWaterRoutine.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isCreatingWR: false,
        errCreatingWR: failure.message,
      ),
      (response) => state = state.copyWith(
        isCreatingWR: false,
        responseMsg: response.message,
      ),
    );
  }

  Future<void> editWaterRoutine(WaterRoutineEntity params) async {
    state = state.copyWith(isEditingWR: true, errEditingWR: '');

    final editWaterRoutine = ref.read(editWaterRoutineUCProvider);
    final result = await editWaterRoutine.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isEditingWR: false,
        errEditingWR: failure.message,
      ),
      (response) => state = state.copyWith(
        isEditingWR: false,
        responseMsg: response.message,
      ),
    );
  }

  Future<void> deleteWaterRoutine(String id) async {
    state = state.copyWith(isDeletingWR: true, errDeletingWR: null);

    final deleteWaterRoutine = ref.read(deleteWaterRoutineUCProvider);
    final result = await deleteWaterRoutine.call(id);

    result.fold(
      (failure) => state = state.copyWith(
        isDeletingWR: false,
        errDeletingWR: failure.message,
      ),
      (response) => state = state.copyWith(
        isDeletingWR: false,
        responseMsg: response.message,
      ),
    );
  }

  Future<void> runWaterRoutine(String id) async {
    state = state.copyWith(isRunningWR: true, errRunningWR: null);

    final runWaterRoutine = ref.read(runWaterRoutineUCProvider);
    final result = await runWaterRoutine.call(id);

    result.fold(
      (failure) => state = state.copyWith(
        isRunningWR: false,
        errRunningWR: failure.message,
      ),
      (response) => state = state.copyWith(
        isRunningWR: false,
        responseMsg: response.message,
      ),
    );
  }
}

// Auth provider
final waterRoutineProvider =
    NotifierProvider<WaterRoutineNotifier, WaterRoutineState>(
      WaterRoutineNotifier.new,
    );
