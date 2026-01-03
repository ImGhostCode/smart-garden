import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/water_routine_entity.dart';
import '../../domain/usecases/get_all_water_routines.dart';
import '../../domain/usecases/get_water_routine_by_id.dart';
import '../../providers/water_routine_providers.dart';

class WaterRoutineState {
  final bool isLoadingWRs;
  final List<WaterRoutineEntity> waterRoutines;
  final String? errLoadingWRs;

  final bool isLoadingWR;
  final WaterRoutineEntity? waterRoutine;
  final String? errLoadingWR;

  final bool isCreatingWR;
  final String? errCreatingWR;

  final bool isEditingWR;
  final String? errEditingWR;

  final String? responseMsg;

  const WaterRoutineState({
    this.isLoadingWRs = false,
    this.isLoadingWR = false,
    this.isCreatingWR = false,
    this.isEditingWR = false,
    this.waterRoutines = const [],
    this.waterRoutine,
    this.responseMsg,
    this.errLoadingWRs,
    this.errLoadingWR,
    this.errCreatingWR,
    this.errEditingWR,
  });

  WaterRoutineState copyWith({
    bool? isLoadingWRs,
    bool? isLoadingWR,
    bool? isCreatingWR,
    bool? isEditingWR,
    List<WaterRoutineEntity>? waterRoutines,
    WaterRoutineEntity? Function()? waterRoutine,
    String? responseMsg,
    String? errLoadingWRs,
    String? errLoadingWR,
    String? errCreatingWR,
    String? errEditingWR,
  }) {
    return WaterRoutineState(
      isLoadingWRs: isLoadingWRs ?? this.isLoadingWRs,
      isLoadingWR: isLoadingWR ?? this.isLoadingWR,
      isCreatingWR: isCreatingWR ?? this.isCreatingWR,
      isEditingWR: isEditingWR ?? this.isEditingWR,
      waterRoutines: waterRoutines ?? this.waterRoutines,
      waterRoutine: waterRoutine != null ? waterRoutine() : this.waterRoutine,
      errLoadingWRs: errLoadingWRs ?? this.errLoadingWRs,
      errLoadingWR: errLoadingWR ?? this.errLoadingWR,
      errCreatingWR: errCreatingWR ?? this.errCreatingWR,
      errEditingWR: errEditingWR ?? this.errEditingWR,
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
      errLoadingWRs: null,
      waterRoutines: [],
    );

    final getAllWaterRoutines = ref.read(getAllWRUCProvider);
    final result = await getAllWaterRoutines.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingWRs: false,
        errLoadingWRs: failure.message,
      ),
      (waterRoutines) => state = state.copyWith(
        isLoadingWRs: false,
        waterRoutines: waterRoutines,
      ),
    );
  }

  Future<void> getWaterRoutineById(GetWRParams params) async {
    state = state.copyWith(
      isLoadingWR: true,
      errLoadingWR: null,
      waterRoutine: () => null,
    );

    final getWaterRoutineById = ref.read(getWRByIdUCProvider);
    final result = await getWaterRoutineById.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingWR: false,
        errLoadingWR: failure.message,
      ),
      (waterRoutine) => state = state.copyWith(
        isLoadingWR: false,
        waterRoutine: () => waterRoutine,
      ),
    );
  }

  Future<void> newWaterRoutine(WaterRoutineEntity params) async {
    state = state.copyWith(isCreatingWR: true, errCreatingWR: null);

    final newWaterRoutine = ref.read(newWaterRoutineUCProvider);
    final result = await newWaterRoutine.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isCreatingWR: false,
        errCreatingWR: failure.message,
      ),
      (waterRoutine) => state = state.copyWith(
        isCreatingWR: false,
        responseMsg: 'Water Routine created successfully',
      ),
    );
  }

  Future<void> editWaterRoutine(WaterRoutineEntity params) async {
    state = state.copyWith(isEditingWR: true, errEditingWR: null);

    final editWaterRoutine = ref.read(editWaterRoutineUCProvider);
    final result = await editWaterRoutine.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isEditingWR: false,
        errEditingWR: failure.message,
      ),
      (waterRoutine) => state = state.copyWith(
        isEditingWR: false,
        responseMsg: 'Water Routine edited successfully',
      ),
    );
  }
}

// Auth provider
final waterRoutineProvider =
    NotifierProvider<WaterRoutineNotifier, WaterRoutineState>(
      WaterRoutineNotifier.new,
    );
