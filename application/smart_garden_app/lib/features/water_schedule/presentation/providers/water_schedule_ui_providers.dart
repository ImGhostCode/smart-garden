// WaterSchedule UI Providers
// Riverpod providers specific to UI state

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/water_schedule_entity.dart';
import 'water_schedule_provider.dart';

// UI state providers
final wsFilterProvider = StateProvider<String>((ref) => '');

final waterScheduleSortOrderProvider = StateProvider<SortOrder>(
  (ref) => SortOrder.asc,
);

enum SortOrder { asc, desc }

final excludeWeatherProvider = StateProvider<bool>((ref) => true);

final selectedWSProvider =
    StateNotifierProvider<WSStepsNotifier, List<WaterScheduleEntity>>(
      (ref) => WSStepsNotifier(),
    );

class WSStepsNotifier extends StateNotifier<List<WaterScheduleEntity>> {
  WSStepsNotifier() : super([]);

  void toggle(WaterScheduleEntity ws) {
    final index = state.indexWhere((s) => s.id == ws.id);

    if (index >= 0) {
      state = [...state]..removeAt(index);
    } else {
      state = [...state, ws];
    }
  }

  bool isSelected(WaterScheduleEntity ws) {
    return state.any((s) => s.id == ws.id);
  }

  void clear() => state = [];

  void add(WaterScheduleEntity ws) {
    state = [...state, ws];
  }
}

// Derived providers - computed from other providers
final filteredWSProvider = Provider<List<WaterScheduleEntity>>((ref) {
  final waterSchedules = ref.watch(waterScheduleProvider).waterSchedules;
  final searchQuery = ref.watch(wsFilterProvider);

  if (searchQuery.isEmpty) {
    return waterSchedules;
  }

  return waterSchedules
      .where(
        (ws) =>
            (ws.name ?? '').toLowerCase().contains(searchQuery.toLowerCase()),
      )
      .toList();
});
