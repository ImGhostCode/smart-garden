// WeatherClient UI Providers
// Riverpod providers specific to UI state

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/notification_client_entity.dart';
import 'notification_client_provider.dart';

// UI state providers
final ncFilterProvider = StateProvider<String>((ref) => '');

final weatherClientSortOrderProvider = StateProvider<SortOrder>(
  (ref) => SortOrder.asc,
);

enum SortOrder { asc, desc }

// Derived providers - computed from other providers
final filteredNCProvider = Provider<List<NotificationClientEntity>>((ref) {
  final notificationClients = ref.watch(notiClientProvider).notiClients;
  final searchQuery = ref.watch(ncFilterProvider);

  if (searchQuery.isEmpty) {
    return notificationClients;
  }

  return notificationClients
      .where(
        (nc) =>
            (nc.name ?? '').toLowerCase().contains(searchQuery.toLowerCase()),
      )
      .toList();
});
