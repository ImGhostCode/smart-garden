import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/plant_entity.dart';
import '../../domain/usecases/get_all_plants.dart';
import '../../domain/usecases/get_plant_by_id.dart';
import '../../providers/plant_providers.dart';

class PlantState {
  final bool isLoadingPlants;
  final List<PlantEntity> plants;
  final String? errLoadingPlants;

  final bool isLoadingPlant;
  final PlantEntity? plant;
  final String? errLoadingPlant;

  final String? responseMsg;

  const PlantState({
    this.isLoadingPlants = false,
    this.isLoadingPlant = false,
    this.plants = const [],
    this.plant,
    this.responseMsg,
    this.errLoadingPlants,
    this.errLoadingPlant,
  });

  PlantState copyWith({
    bool? isLoadingPlants,
    bool? isLoadingPlant,
    List<PlantEntity>? plants,
    PlantEntity? plant,
    String? responseMsg,
    String? errLoadingPlants,
    String? errLoadingPlant,
  }) {
    return PlantState(
      isLoadingPlants: isLoadingPlants ?? this.isLoadingPlants,
      isLoadingPlant: isLoadingPlant ?? this.isLoadingPlant,
      plants: plants ?? this.plants,
      plant:
          plant ??
          ((plant == null && this.plant != null && plant == null)
              ? null
              : this.plant),
      errLoadingPlants: errLoadingPlants ?? this.errLoadingPlants,
      errLoadingPlant: errLoadingPlant ?? this.errLoadingPlant,
      responseMsg: responseMsg,
    );
  }
}

// Auth notifier
class PlantNotifier extends Notifier<PlantState> {
  @override
  PlantState build() {
    return const PlantState();
  }

  Future<void> getAllPlant(GetAllPlantParams params) async {
    state = state.copyWith(
      isLoadingPlants: true,
      errLoadingPlants: null,
      plants: [],
    );

    final getAllPlants = ref.read(getAllPlantUCProvider);
    final result = await getAllPlants.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingPlants: false,
        errLoadingPlants: failure.message,
      ),
      (plants) =>
          state = state.copyWith(isLoadingPlants: false, plants: plants),
    );
  }

  Future<void> getPlantById({required String id}) async {
    state = state.copyWith(
      isLoadingPlant: true,
      errLoadingPlant: null,
      plant: null,
    );

    final getPlantById = ref.read(getPlantByIdUCProvider);
    final result = await getPlantById.call(PlantParams(id: id));

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingPlant: false,
        errLoadingPlant: failure.message,
      ),
      (plant) => state = state.copyWith(isLoadingPlant: false, plant: plant),
    );
  }
}

// Auth provider
final plantProvider = NotifierProvider<PlantNotifier, PlantState>(
  PlantNotifier.new,
);
