// Plant Providers
// Riverpod providers for the plant feature

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/storage_providers.dart';
import '../data/datasources/plant_local_datasource.dart';
import '../data/datasources/plant_remote_datasource.dart';
import '../data/repositories/plant_repository_impl.dart';
import '../domain/repositories/plant_repository.dart';
import '../domain/usecases/get_all_plants.dart';
import '../domain/usecases/get_plant_by_id.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Data sources
final plantRemoteDataSourceProvider = Provider<PlantRemoteDataSource>(
  (ref) => PlantRemoteDataSourceImpl(),
);

final plantLocalDataSourceProvider = Provider<PlantLocalDataSource>(
  (ref) => PlantLocalDataSourceImpl(ref.read(localStorageServiceProvider)),
);

// Repository
final plantRepositoryProvider = Provider<PlantRepository>(
  (ref) => PlantRepositoryImpl(
    remoteDataSource: ref.read(plantRemoteDataSourceProvider),
    localDataSource: ref.read(plantLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

// Use cases
final getAllPlantUCProvider = Provider<GetAllPlants>(
  (ref) => GetAllPlants(ref.read(plantRepositoryProvider)),
);

final getPlantByIdUCProvider = Provider<GetPlantById>(
  (ref) => GetPlantById(ref.read(plantRepositoryProvider)),
);
