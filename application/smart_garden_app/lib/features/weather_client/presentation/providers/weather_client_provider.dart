import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/weather_client_entity.dart';
import '../../domain/usecases/get_all_weather_clients.dart';
import '../../domain/usecases/get_weather_client_by_id.dart';
import '../../providers/weather_client_providers.dart';

class WeatherClientState {
  final bool isLoadingWCs;
  final List<WeatherClientEntity> weatherClients;
  final String? errLoadingWCs;

  final bool isLoadingWC;
  final WeatherClientEntity? weatherClient;
  final String? errLoadingWC;

  final bool isLoadingWeather;
  final String? errLoadingWeather;

  final bool isCreatingWC;
  final String? errCreatingWC;

  final bool isEditingWC;
  final String? errEditingWC;

  final String? responseMsg;

  const WeatherClientState({
    this.isLoadingWCs = false,
    this.isLoadingWC = false,
    this.isLoadingWeather = false,
    this.isCreatingWC = false,
    this.isEditingWC = false,
    this.weatherClients = const [],
    this.weatherClient,
    this.responseMsg,
    this.errLoadingWCs,
    this.errLoadingWC,
    this.errLoadingWeather,
    this.errCreatingWC,
    this.errEditingWC,
  });

  WeatherClientState copyWith({
    bool? isLoadingWCs,
    bool? isLoadingWC,
    bool? isLoadingWeather,
    bool? isCreatingWC,
    bool? isEditingWC,
    List<WeatherClientEntity>? weatherClients,
    WeatherClientEntity? Function()? weatherClient,
    String? responseMsg,
    String? errLoadingWCs,
    String? errLoadingWC,
    String? errLoadingWeather,
    String? errCreatingWC,
    String? errEditingWC,
  }) {
    return WeatherClientState(
      isLoadingWCs: isLoadingWCs ?? this.isLoadingWCs,
      isLoadingWC: isLoadingWC ?? this.isLoadingWC,
      isLoadingWeather: isLoadingWeather ?? this.isLoadingWeather,
      isCreatingWC: isCreatingWC ?? this.isCreatingWC,
      isEditingWC: isEditingWC ?? this.isEditingWC,
      weatherClients: weatherClients ?? this.weatherClients,
      weatherClient: weatherClient != null
          ? weatherClient()
          : this.weatherClient,
      errLoadingWCs: errLoadingWCs ?? this.errLoadingWCs,
      errLoadingWC: errLoadingWC ?? this.errLoadingWC,
      errLoadingWeather: errLoadingWeather ?? this.errLoadingWeather,
      errCreatingWC: errCreatingWC ?? this.errCreatingWC,
      errEditingWC: errEditingWC ?? this.errEditingWC,
      responseMsg: responseMsg,
    );
  }
}

// Auth notifier
class WeatherClientNotifier extends Notifier<WeatherClientState> {
  @override
  WeatherClientState build() {
    return const WeatherClientState();
  }

  Future<void> getAllWeatherClients(GetAllWeatherClientsParams params) async {
    state = state.copyWith(
      isLoadingWCs: true,
      errLoadingWCs: null,
      weatherClients: [],
    );

    final getAllWeatherClients = ref.read(getAllWeatherClientsUCProvider);
    final result = await getAllWeatherClients.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingWCs: false,
        errLoadingWCs: failure.message,
      ),
      (weatherClients) => state = state.copyWith(
        isLoadingWCs: false,
        weatherClients: weatherClients,
      ),
    );
  }

  Future<void> getWeatherClientById(GetWeatherClientParams params) async {
    state = state.copyWith(
      isLoadingWC: true,
      errLoadingWC: null,
      weatherClient: () => null,
    );

    final getWeatherClientById = ref.read(getWeatherClientByIdUCProvider);
    final result = await getWeatherClientById.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingWC: false,
        errLoadingWC: failure.message,
      ),
      (weatherClient) => state = state.copyWith(
        isLoadingWC: false,
        weatherClient: () => weatherClient,
      ),
    );
  }

  Future<void> getWeatherData(String weatherClientId) async {
    state = state.copyWith(
      isLoadingWeather: true,
      errLoadingWeather: null,
      weatherClients: state.weatherClients.map((e) {
        if (e.id == weatherClientId) {
          return e.copyWith(latestWeatherData: null, error: null);
        }
        return e;
      }).toList(),
    );

    final getWeatherData = ref.read(getWeatherDataUCProvider);
    final result = await getWeatherData.call(weatherClientId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingWeather: false,
        errLoadingWeather: failure.message,
        weatherClients: state.weatherClients.map((e) {
          if (e.id == weatherClientId) {
            return e.copyWith(error: failure.message);
          }
          return e;
        }).toList(),
      ),
      (weatherClient) => state = state.copyWith(
        isLoadingWeather: false,
        weatherClients: state.weatherClients.map((e) {
          if (e.id == weatherClientId) {
            return e.copyWith(latestWeatherData: weatherClient);
          }
          return e;
        }).toList(),
      ),
    );
  }

  Future<void> newWeatherClient(WeatherClientEntity weatherClient) async {
    state = state.copyWith(isCreatingWC: true, errCreatingWC: null);

    final newWeatherClient = ref.read(newWeatherClientUCProvider);
    final result = await newWeatherClient.call(weatherClient);

    result.fold(
      (failure) => state = state.copyWith(
        isCreatingWC: false,
        errCreatingWC: failure.message,
      ),
      (newWC) => state = state.copyWith(
        isCreatingWC: false,
        responseMsg: 'Weather client created successfully',
      ),
    );
  }

  Future<void> editWeatherClient(WeatherClientEntity weatherClient) async {
    state = state.copyWith(isEditingWC: true, errEditingWC: null);

    final editWeatherClient = ref.read(editWeatherClientUCProvider);
    final result = await editWeatherClient.call(weatherClient);

    result.fold(
      (failure) => state = state.copyWith(
        isEditingWC: false,
        errEditingWC: failure.message,
      ),
      (editedWC) => state = state.copyWith(
        isEditingWC: false,
        responseMsg: 'Weather client edited successfully',
      ),
    );
  }
}

// Auth provider
final weatherClientProvider =
    NotifierProvider<WeatherClientNotifier, WeatherClientState>(
      WeatherClientNotifier.new,
    );
