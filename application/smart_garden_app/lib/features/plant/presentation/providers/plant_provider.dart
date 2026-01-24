import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/plant_entity.dart';
import '../../domain/usecases/add_plant.dart';
import '../../domain/usecases/delete_plant.dart';
import '../../domain/usecases/edit_plant.dart';
import '../../domain/usecases/get_all_plants.dart';
import '../../domain/usecases/get_plant_by_id.dart';
import '../../providers/plant_providers.dart';

class PlantState {
  final bool isLoadingPlants;
  final List<PlantEntity> plants;
  final String errLoadingPlants;

  final bool isLoadingPlant;
  final PlantEntity? plant;
  final String errLoadingPlant;

  final bool isEditingPlant;
  final String errEditingPlant;

  final bool isCreatingPlant;
  final String errCreatingPlant;

  final bool isDeletingPlant;
  final String errDeletingPlant;

  final String? responseMsg;

  const PlantState({
    this.isLoadingPlants = false,
    this.isLoadingPlant = false,
    this.isCreatingPlant = false,
    this.isEditingPlant = false,
    this.isDeletingPlant = false,
    this.plants = const [],
    this.plant,
    this.responseMsg,
    this.errLoadingPlants = '',
    this.errLoadingPlant = '',
    this.errCreatingPlant = '',
    this.errEditingPlant = '',
    this.errDeletingPlant = '',
  });

  PlantState copyWith({
    bool? isLoadingPlants,
    bool? isLoadingPlant,
    bool? isCreatingPlant,
    bool? isEditingPlant,
    bool? isDeletingPlant,
    List<PlantEntity>? plants,
    PlantEntity? Function()? plant,
    String? responseMsg,
    String? errLoadingPlants,
    String? errLoadingPlant,
    String? errCreatingPlant,
    String? errEditingPlant,
    String? errDeletingPlant,
  }) {
    return PlantState(
      isLoadingPlants: isLoadingPlants ?? this.isLoadingPlants,
      isLoadingPlant: isLoadingPlant ?? this.isLoadingPlant,
      isCreatingPlant: isCreatingPlant ?? this.isCreatingPlant,
      isEditingPlant: isEditingPlant ?? this.isEditingPlant,
      isDeletingPlant: isDeletingPlant ?? this.isDeletingPlant,
      plants: plants ?? this.plants,
      plant: plant != null ? plant() : this.plant,
      errLoadingPlants: errLoadingPlants ?? this.errLoadingPlants,
      errLoadingPlant: errLoadingPlant ?? this.errLoadingPlant,
      errCreatingPlant: errCreatingPlant ?? this.errCreatingPlant,
      errEditingPlant: errEditingPlant ?? this.errEditingPlant,
      errDeletingPlant: errDeletingPlant ?? this.errDeletingPlant,
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
      errLoadingPlants: '',
      plants: [],
    );

    final getAllPlants = ref.read(getAllPlantUCProvider);
    final result = await getAllPlants.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingPlants: false,
        errLoadingPlants: failure.message,
      ),
      (response) =>
          state = state.copyWith(isLoadingPlants: false, plants: response.data),
    );
  }

  Future<void> getPlantById(GetPlantParams params) async {
    state = state.copyWith(
      isLoadingPlant: true,
      errLoadingPlant: '',
      plant: () => null,
    );

    final getPlantById = ref.read(getPlantByIdUCProvider);
    final result = await getPlantById.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingPlant: false,
        errLoadingPlant: failure.message,
      ),
      (response) => state = state.copyWith(
        isLoadingPlant: false,
        plant: () => response.data,
      ),
    );
  }

  Future<void> addPlant(AddPlantParams params) async {
    state = state.copyWith(isCreatingPlant: true, errCreatingPlant: '');

    final addPlant = ref.read(newPlantUCProvider);
    final result = await addPlant.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isCreatingPlant: false,
        errCreatingPlant: failure.message,
      ),
      (response) => state = state.copyWith(
        isCreatingPlant: false,
        responseMsg: response.message,
      ),
    );
  }

  Future<void> editPlant(EditPlantParams params) async {
    state = state.copyWith(isEditingPlant: true, errEditingPlant: '');

    final editPlant = ref.read(editPlantUCProvider);
    final result = await editPlant.call(params);
    result.fold(
      (failure) => state = state.copyWith(
        isEditingPlant: false,
        errEditingPlant: failure.message,
      ),
      (response) => state = state.copyWith(
        isEditingPlant: false,
        plant: () => response.data,
        responseMsg: response.message,
      ),
    );
  }

  Future<void> deletePlant(DeletePlantParams params) async {
    state = state.copyWith(isDeletingPlant: true, errDeletingPlant: '');

    final deletePlant = ref.read(deletePlantUCProvider);
    final result = await deletePlant.call(params);
    result.fold(
      (failure) => state = state.copyWith(
        isDeletingPlant: false,
        errDeletingPlant: failure.message,
      ),
      (response) => state = state.copyWith(
        isDeletingPlant: false,
        responseMsg: response.message,
      ),
    );
  }
}

// Auth provider
final plantProvider = NotifierProvider<PlantNotifier, PlantState>(
  PlantNotifier.new,
);
