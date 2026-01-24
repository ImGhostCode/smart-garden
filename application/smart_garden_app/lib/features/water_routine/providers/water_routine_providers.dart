// WaterRoutine Providers
// Riverpod providers for the water_routine feature

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/storage_providers.dart';
import '../data/datasources/water_routine_local_datasource.dart';
import '../data/datasources/water_routine_remote_datasource.dart';
import '../data/repositories/water_routine_repository_impl.dart';
import '../domain/repositories/water_routine_repository.dart';
import '../domain/usecases/delete_water_routine.dart';
import '../domain/usecases/edit_water_routine.dart';
import '../domain/usecases/get_all_water_routines.dart';
import '../domain/usecases/get_water_routine_by_id.dart';
import '../domain/usecases/new_water_routine.dart';
import '../domain/usecases/run_water_routine.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Data sources
final waterRoutineRemoteDataSourceProvider =
    Provider<WaterRoutineRemoteDataSource>(
      (ref) => WaterRoutineRemoteDataSourceImpl(ref.watch(apiClientProvider)),
    );

final waterRoutineLocalDataSourceProvider =
    Provider<WaterRoutineLocalDataSource>(
      (ref) => WaterRoutineLocalDataSourceImpl(
        ref.read(localStorageServiceProvider),
      ),
    );

// Repository
final waterRoutineRepositoryProvider = Provider<WaterRoutineRepository>(
  (ref) => WaterRoutineRepositoryImpl(
    remoteDataSource: ref.read(waterRoutineRemoteDataSourceProvider),
    localDataSource: ref.read(waterRoutineLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

// Use cases
final getAllWRUCProvider = Provider<GetAllWaterRoutines>(
  (ref) => GetAllWaterRoutines(ref.read(waterRoutineRepositoryProvider)),
);

final getWRByIdUCProvider = Provider<GetWaterRoutineById>(
  (ref) => GetWaterRoutineById(ref.read(waterRoutineRepositoryProvider)),
);

final newWaterRoutineUCProvider = Provider<NewWaterRoutine>(
  (ref) => NewWaterRoutine(ref.read(waterRoutineRepositoryProvider)),
);

final editWaterRoutineUCProvider = Provider<EditWaterRoutine>(
  (ref) => EditWaterRoutine(ref.read(waterRoutineRepositoryProvider)),
);

final deleteWaterRoutineUCProvider = Provider<DeleteWaterRoutine>(
  (ref) => DeleteWaterRoutine(ref.read(waterRoutineRepositoryProvider)),
);

final runWaterRoutineUCProvider = Provider<RunWaterRoutine>(
  (ref) => RunWaterRoutine(ref.read(waterRoutineRepositoryProvider)),
);
