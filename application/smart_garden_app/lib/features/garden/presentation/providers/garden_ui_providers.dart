// Garden UI Providers
// Riverpod providers specific to UI state

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/garden_entity.dart';
import 'garden_provider.dart';

// UI state providers
final gardenFilterProvider = StateProvider<String>((ref) => '');

final gardenSortOrderProvider = StateProvider<SortOrder>(
  (ref) => SortOrder.asc,
);

enum SortOrder { asc, desc }

// Derived providers - computed from other providers
final filteredGardensProvider = Provider<List<GardenEntity>>((ref) {
  final gardens = ref.watch(gardenProvider).gardens;
  final searchQuery = ref.watch(gardenFilterProvider);

  if (searchQuery.isEmpty) {
    return gardens;
  }

  return gardens
      .where(
        (garden) => (garden.name ?? '').toLowerCase().contains(
          searchQuery.toLowerCase(),
        ),
      )
      .toList();
});
