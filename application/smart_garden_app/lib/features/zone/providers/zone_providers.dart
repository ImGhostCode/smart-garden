// Zone Providers
// Riverpod providers for the zone feature

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/storage_providers.dart';
import '../data/datasources/zone_local_datasource.dart';
import '../data/datasources/zone_remote_datasource.dart';
import '../data/repositories/zone_repository_impl.dart';
import '../domain/repositories/zone_repository.dart';
import '../domain/usecases/get_all_zones.dart';
import '../domain/usecases/get_water_history.dart';
import '../domain/usecases/get_zone_by_id.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Data sources
final zoneRemoteDataSourceProvider = Provider<ZoneRemoteDataSource>(
  (ref) => ZoneRemoteDataSourceImpl(),
);

final zoneLocalDataSourceProvider = Provider<ZoneLocalDataSource>(
  (ref) => ZoneLocalDataSourceImpl(ref.read(localStorageServiceProvider)),
);

// Repository
final zoneRepositoryProvider = Provider<ZoneRepository>(
  (ref) => ZoneRepositoryImpl(
    remoteDataSource: ref.read(zoneRemoteDataSourceProvider),
    localDataSource: ref.read(zoneLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

// Use cases
final getAllZoneUCProvider = Provider<GetAllZones>(
  (ref) => GetAllZones(ref.read(zoneRepositoryProvider)),
);

final getZoneByIdUCProvider = Provider<GetZoneById>(
  (ref) => GetZoneById(ref.read(zoneRepositoryProvider)),
);

final getWaterHistoryUCProvider = Provider<GetWaterHistory>(
  (ref) => GetWaterHistory(ref.read(zoneRepositoryProvider)),
);
