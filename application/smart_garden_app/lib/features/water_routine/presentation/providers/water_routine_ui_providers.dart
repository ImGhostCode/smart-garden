// WaterRoutine UI Providers
// Riverpod providers specific to UI state

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../zone/domain/entities/zone_entity.dart';
import '../../domain/entities/water_routine_entity.dart';
import 'water_routine_provider.dart';

// UI state providers
final wrFilterProvider = StateProvider<String>((ref) => '');

final waterRoutineSortOrderProvider = StateProvider<SortOrder>(
  (ref) => SortOrder.asc,
);

enum SortOrder { asc, desc }

final selectedZonesProvider =
    StateNotifierProvider<SelectedZonesNotifier, List<ZoneEntity>>(
      (ref) => SelectedZonesNotifier(),
    );

class SelectedZonesNotifier extends StateNotifier<List<ZoneEntity>> {
  SelectedZonesNotifier() : super([]);

  void toggle(ZoneEntity zone) {
    final exists = state.any((z) => z.id == zone.id);
    if (exists) {
      state = state.where((z) => z.id != zone.id).toList();
    } else {
      state = [...state, zone];
    }
  }

  bool isSelected(String zoneId) {
    return state.any((z) => z.id == zoneId);
  }

  void clear() {
    state = [];
  }
}

final selectedWRStepsProvider =
    StateNotifierProvider<WRStepsNotifier, List<StepEntity>>(
      (ref) => WRStepsNotifier(),
    );

class WRStepsNotifier extends StateNotifier<List<StepEntity>> {
  WRStepsNotifier() : super([]);

  void toggleZone(ZoneEntity zone) {
    final index = state.indexWhere((s) => s.zone?.id == zone.id);

    if (index >= 0) {
      state = [...state]..removeAt(index);
    } else {
      state = [...state, StepEntity(zone: zone)];
    }
  }

  void updateDuration(String zoneId, int durationMs) {
    state = [
      for (final step in state)
        if (step.zone?.id == zoneId)
          step.copyWith(durationMs: durationMs)
        else
          step,
    ];
  }

  void clear() => state = [];

  void addStep(StepEntity step) {
    state = [...state, step];
  }
}

// Derived providers - computed from other providers
final filteredWRProvider = Provider<List<WaterRoutineEntity>>((ref) {
  final waterRoutines = ref.watch(waterRoutineProvider).waterRoutines;
  final searchQuery = ref.watch(wrFilterProvider);

  if (searchQuery.isEmpty) {
    return waterRoutines;
  }

  return waterRoutines
      .where(
        (wr) =>
            (wr.name ?? '').toLowerCase().contains(searchQuery.toLowerCase()),
      )
      .toList();
});
