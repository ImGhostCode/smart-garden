// WaterSchedule UI Providers
// Riverpod providers specific to UI state

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/water_schedule_entity.dart';

// UI state providers
final waterScheduleFilterProvider = StateProvider<String>((ref) => '');

final waterScheduleSortOrderProvider = StateProvider<SortOrder>(
  (ref) => SortOrder.asc,
);

enum SortOrder { asc, desc }

final selectedWSProvider =
    StateNotifierProvider<WRStepsNotifier, List<WaterScheduleEntity>>(
      (ref) => WRStepsNotifier(),
    );

class WRStepsNotifier extends StateNotifier<List<WaterScheduleEntity>> {
  WRStepsNotifier() : super([]);

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
