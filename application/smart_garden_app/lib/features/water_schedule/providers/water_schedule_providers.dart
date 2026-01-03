// WaterSchedule Providers
// Riverpod providers for the water_schedule feature

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/storage_providers.dart';
import '../data/datasources/water_schedule_local_datasource.dart';
import '../data/datasources/water_schedule_remote_datasource.dart';
import '../data/repositories/water_schedule_repository_impl.dart';
import '../domain/repositories/water_schedule_repository.dart';
import '../domain/usecases/edit_water_schedule.dart';
import '../domain/usecases/get_all_water_schedules.dart';
import '../domain/usecases/get_water_schedule_by_id.dart';
import '../domain/usecases/new_water_schedule.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Data sources
final waterScheduleRemoteDataSourceProvider =
    Provider<WaterScheduleRemoteDataSource>(
      (ref) => WaterScheduleRemoteDataSourceImpl(),
    );

final waterScheduleLocalDataSourceProvider =
    Provider<WaterScheduleLocalDataSource>(
      (ref) => WaterScheduleLocalDataSourceImpl(
        ref.read(localStorageServiceProvider),
      ),
    );

// Repository
final waterScheduleRepositoryProvider = Provider<WaterScheduleRepository>(
  (ref) => WaterScheduleRepositoryImpl(
    remoteDataSource: ref.read(waterScheduleRemoteDataSourceProvider),
    localDataSource: ref.read(waterScheduleLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

// Use cases
final getAllWSUCProvider = Provider<GetAllWaterSchedules>(
  (ref) => GetAllWaterSchedules(ref.read(waterScheduleRepositoryProvider)),
);

final getWSByIdUCProvider = Provider<GetWaterScheduleById>(
  (ref) => GetWaterScheduleById(ref.read(waterScheduleRepositoryProvider)),
);

final newWaterScheduleUCProvider = Provider<NewWaterSchedule>(
  (ref) => NewWaterSchedule(ref.read(waterScheduleRepositoryProvider)),
);

final editWaterScheduleUCProvider = Provider<EditWaterSchedule>(
  (ref) => EditWaterSchedule(ref.read(waterScheduleRepositoryProvider)),
);
