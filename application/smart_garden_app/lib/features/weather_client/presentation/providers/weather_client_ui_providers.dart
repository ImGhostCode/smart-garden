// WeatherClient UI Providers
// Riverpod providers specific to UI state

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/weather_client_entity.dart';
import 'weather_client_provider.dart';

// UI state providers
final wcFilterProvider = StateProvider<String>((ref) => '');

final weatherClientSortOrderProvider = StateProvider<SortOrder>(
  (ref) => SortOrder.asc,
);

enum SortOrder { asc, desc }

// Derived providers - computed from other providers
final filteredWCProvider = Provider<List<WeatherClientEntity>>((ref) {
  final weatherClient = ref.watch(weatherClientProvider).weatherClients;
  final searchQuery = ref.watch(wcFilterProvider);

  if (searchQuery.isEmpty) {
    return weatherClient;
  }

  return weatherClient
      .where(
        (wc) =>
            (wc.name ?? '').toLowerCase().contains(searchQuery.toLowerCase()),
      )
      .toList();
});
