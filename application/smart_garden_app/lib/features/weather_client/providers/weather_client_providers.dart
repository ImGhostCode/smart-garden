// WeatherClient Providers
// Riverpod providers for the weather_client feature

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/storage_providers.dart';
import '../data/datasources/weather_client_local_datasource.dart';
import '../data/datasources/weather_client_remote_datasource.dart';
import '../data/repositories/weather_client_repository_impl.dart';
import '../domain/repositories/weather_client_repository.dart';
import '../domain/usecases/edit_weather_client.dart';
import '../domain/usecases/get_all_weather_clients.dart';
import '../domain/usecases/get_weather_client_by_id.dart';
import '../domain/usecases/get_weather_data.dart';
import '../domain/usecases/new_weather_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Data sources
final weatherClientRemoteDataSourceProvider =
    Provider<WeatherClientRemoteDataSource>(
      (ref) => WeatherClientRemoteDataSourceImpl(),
    );

final weatherClientLocalDataSourceProvider =
    Provider<WeatherClientLocalDataSource>(
      (ref) => WeatherClientLocalDataSourceImpl(
        ref.read(localStorageServiceProvider),
      ),
    );

// Repository
final weatherClientRepositoryProvider = Provider<WeatherClientRepository>(
  (ref) => WeatherClientRepositoryImpl(
    remoteDataSource: ref.read(weatherClientRemoteDataSourceProvider),
    localDataSource: ref.read(weatherClientLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

// Use cases
final getAllWeatherClientsUCProvider = Provider<GetAllWeatherClients>(
  (ref) => GetAllWeatherClients(ref.read(weatherClientRepositoryProvider)),
);

final getWeatherClientByIdUCProvider = Provider<GetWeatherClientById>(
  (ref) => GetWeatherClientById(ref.read(weatherClientRepositoryProvider)),
);

final getWeatherDataUCProvider = Provider<GetWeatherData>(
  (ref) => GetWeatherData(ref.read(weatherClientRepositoryProvider)),
);

final newWeatherClientUCProvider = Provider<NewWeatherClient>(
  (ref) => NewWeatherClient(ref.read(weatherClientRepositoryProvider)),
);

final editWeatherClientUCProvider = Provider<EditWeatherClient>(
  (ref) => EditWeatherClient(ref.read(weatherClientRepositoryProvider)),
);
