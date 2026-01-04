import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/weather_client_entity.dart';
import '../../domain/usecases/get_all_weather_clients.dart';
import '../../domain/usecases/get_weather_client_by_id.dart';
import '../../providers/weather_client_providers.dart';

class WeatherClientState {
  final bool isLoadingWCs;
  final List<WeatherClientEntity> weatherClients;
  final String errLoadingWCs;

  final bool isLoadingWC;
  final WeatherClientEntity? weatherClient;
  final String errLoadingWC;

  final bool isLoadingWeather;
  final String errLoadingWeather;

  final bool isCreatingWC;
  final String errCreatingWC;

  final bool isEditingWC;
  final String errEditingWC;

  final bool isDeletingWC;
  final String errDeletingWC;

  final String? responseMsg;

  const WeatherClientState({
    this.isLoadingWCs = false,
    this.isLoadingWC = false,
    this.isLoadingWeather = false,
    this.isCreatingWC = false,
    this.isEditingWC = false,
    this.isDeletingWC = false,
    this.weatherClients = const [],
    this.weatherClient,
    this.responseMsg,
    this.errLoadingWCs = "",
    this.errLoadingWC = "",
    this.errLoadingWeather = "",
    this.errCreatingWC = "",
    this.errEditingWC = "",
    this.errDeletingWC = "",
  });

  WeatherClientState copyWith({
    bool? isLoadingWCs,
    bool? isLoadingWC,
    bool? isLoadingWeather,
    bool? isCreatingWC,
    bool? isEditingWC,
    bool? isDeletingWC,
    List<WeatherClientEntity>? weatherClients,
    WeatherClientEntity? Function()? weatherClient,
    String? responseMsg,
    String? errLoadingWCs,
    String? errLoadingWC,
    String? errLoadingWeather,
    String? errCreatingWC,
    String? errEditingWC,
    String? errDeletingWC,
  }) {
    return WeatherClientState(
      isLoadingWCs: isLoadingWCs ?? this.isLoadingWCs,
      isLoadingWC: isLoadingWC ?? this.isLoadingWC,
      isLoadingWeather: isLoadingWeather ?? this.isLoadingWeather,
      isCreatingWC: isCreatingWC ?? this.isCreatingWC,
      isEditingWC: isEditingWC ?? this.isEditingWC,
      isDeletingWC: isDeletingWC ?? this.isDeletingWC,
      weatherClients: weatherClients ?? this.weatherClients,
      weatherClient: weatherClient != null
          ? weatherClient()
          : this.weatherClient,
      errLoadingWCs: errLoadingWCs ?? this.errLoadingWCs,
      errLoadingWC: errLoadingWC ?? this.errLoadingWC,
      errLoadingWeather: errLoadingWeather ?? this.errLoadingWeather,
      errCreatingWC: errCreatingWC ?? this.errCreatingWC,
      errEditingWC: errEditingWC ?? this.errEditingWC,
      errDeletingWC: errDeletingWC ?? this.errDeletingWC,
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
      errLoadingWCs: '',
      weatherClients: [],
    );

    final getAllWeatherClients = ref.read(getAllWeatherClientsUCProvider);
    final result = await getAllWeatherClients.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingWCs: false,
        errLoadingWCs: failure.message,
      ),
      (response) => state = state.copyWith(
        isLoadingWCs: false,
        weatherClients: response.data,
      ),
    );
  }

  Future<void> getWeatherClientById(GetWeatherClientParams params) async {
    state = state.copyWith(
      isLoadingWC: true,
      errLoadingWC: '',
      weatherClient: () => null,
    );

    final getWeatherClientById = ref.read(getWeatherClientByIdUCProvider);
    final result = await getWeatherClientById.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingWC: false,
        errLoadingWC: failure.message,
      ),
      (response) => state = state.copyWith(
        isLoadingWC: false,
        weatherClient: () => response.data,
      ),
    );
  }

  Future<void> getWeatherData(String weatherClientId) async {
    state = state.copyWith(
      isLoadingWeather: true,
      errLoadingWeather: '',
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
      (response) => state = state.copyWith(
        isLoadingWeather: false,
        weatherClients: state.weatherClients.map((e) {
          if (e.id == weatherClientId) {
            return e.copyWith(latestWeatherData: response.data);
          }
          return e;
        }).toList(),
      ),
    );
  }

  Future<void> newWeatherClient(WeatherClientEntity weatherClient) async {
    state = state.copyWith(isCreatingWC: true, errCreatingWC: '');

    final newWeatherClient = ref.read(newWeatherClientUCProvider);
    final result = await newWeatherClient.call(weatherClient);

    result.fold(
      (failure) => state = state.copyWith(
        isCreatingWC: false,
        errCreatingWC: failure.message,
      ),
      (response) => state = state.copyWith(
        isCreatingWC: false,
        responseMsg: response.message,
      ),
    );
  }

  Future<void> editWeatherClient(WeatherClientEntity weatherClient) async {
    state = state.copyWith(isEditingWC: true, errEditingWC: '');

    final editWeatherClient = ref.read(editWeatherClientUCProvider);
    final result = await editWeatherClient.call(weatherClient);

    result.fold(
      (failure) => state = state.copyWith(
        isEditingWC: false,
        errEditingWC: failure.message,
      ),
      (response) => state = state.copyWith(
        isEditingWC: false,
        responseMsg: response.message,
      ),
    );
  }

  Future<void> deleteWeatherClient(String id) async {
    state = state.copyWith(isDeletingWC: true, errDeletingWC: null);

    final deleteWeatherClient = ref.read(deleteWeatherClientUCProvider);
    final result = await deleteWeatherClient.call(id);

    result.fold(
      (failure) => state = state.copyWith(
        isDeletingWC: false,
        errDeletingWC: failure.message,
      ),
      (response) => state = state.copyWith(
        isDeletingWC: false,
        responseMsg: response.message,
      ),
    );
  }
}

// Auth provider
final weatherClientProvider =
    NotifierProvider<WeatherClientNotifier, WeatherClientState>(
      WeatherClientNotifier.new,
    );
