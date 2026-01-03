// Garden Providers
// Riverpod providers for the garden feature

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/storage_providers.dart';
import '../data/datasources/garden_local_datasource.dart';
import '../data/datasources/garden_remote_datasource.dart';
import '../data/repositories/garden_repository_impl.dart';
import '../domain/repositories/garden_repository.dart';
import '../domain/usecases/create_garden.dart';
import '../domain/usecases/edit_garden.dart';
import '../domain/usecases/get_all_gardens.dart';
import '../domain/usecases/get_garden_by_id.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Data sources
final gardenRemoteDataSourceProvider = Provider<GardenRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GardenRemoteDataSourceImpl(apiClient);
});

final gardenLocalDataSourceProvider = Provider<GardenLocalDataSource>(
  (ref) => GardenLocalDataSourceImpl(ref.read(localStorageServiceProvider)),
);

// Repository
final gardenRepositoryProvider = Provider<GardenRepository>(
  (ref) => GardenRepositoryImpl(
    remoteDataSource: ref.read(gardenRemoteDataSourceProvider),
    localDataSource: ref.read(gardenLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

// Use cases
final getAllGardenUCProvider = Provider<GetAllGardens>(
  (ref) => GetAllGardens(ref.read(gardenRepositoryProvider)),
);

final getGardenByIdUCProvider = Provider<GetGardenById>(
  (ref) => GetGardenById(ref.read(gardenRepositoryProvider)),
);

final createGardenUCProvider = Provider<CreateGarden>(
  (ref) => CreateGarden(ref.read(gardenRepositoryProvider)),
);

final editGardenUCProvider = Provider<EditGarden>(
  (ref) => EditGarden(ref.read(gardenRepositoryProvider)),
);
