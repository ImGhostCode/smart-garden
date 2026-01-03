import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/garden_entity.dart';
import '../../domain/usecases/get_all_gardens.dart';
import '../../domain/usecases/get_garden_by_id.dart';
import '../../providers/garden_providers.dart';

class GardenState {
  final bool isLoadingGardens;
  final List<GardenEntity> gardens;
  final String? errLoadingGardens;

  final bool isLoadingGarden;
  final GardenEntity? garden;
  final String? errLoadingGarden;

  final bool isCreatingGarden;
  final String? errCreatingGarden;

  final bool isEditingGarden;
  final String? errEditingGarden;

  final String? responseMsg;

  const GardenState({
    this.isLoadingGardens = false,
    this.isLoadingGarden = false,
    this.isCreatingGarden = false,
    this.isEditingGarden = false,
    this.gardens = const [],
    this.garden,
    this.responseMsg,
    this.errLoadingGardens,
    this.errLoadingGarden,
    this.errCreatingGarden,
    this.errEditingGarden,
  });

  GardenState copyWith({
    bool? isLoadingGardens,
    bool? isLoadingGarden,
    bool? isCreatingGarden,
    bool? isEditingGarden,
    List<GardenEntity>? gardens,
    GardenEntity? Function()? garden,
    String? responseMsg,
    String? errLoadingGardens,
    String? errLoadingGarden,
    String? errCreatingGarden,
    String? errEditingGarden,
  }) {
    return GardenState(
      isLoadingGardens: isLoadingGardens ?? this.isLoadingGardens,
      isLoadingGarden: isLoadingGarden ?? this.isLoadingGarden,
      isCreatingGarden: isCreatingGarden ?? this.isCreatingGarden,
      isEditingGarden: isEditingGarden ?? this.isEditingGarden,
      gardens: gardens ?? this.gardens,
      garden: garden != null ? garden() : this.garden,
      errLoadingGardens: errLoadingGardens ?? this.errLoadingGardens,
      errLoadingGarden: errLoadingGarden ?? this.errLoadingGarden,
      errCreatingGarden: errCreatingGarden ?? this.errCreatingGarden,
      errEditingGarden: errEditingGarden ?? this.errEditingGarden,
      responseMsg: responseMsg,
    );
  }
}

// Auth notifier
class GardenNotifier extends Notifier<GardenState> {
  @override
  GardenState build() {
    return const GardenState();
  }

  Future<void> getAllGarden(GetAllGardenParams params) async {
    state = state.copyWith(
      isLoadingGardens: true,
      errLoadingGardens: null,
      gardens: [],
    );

    final getAllGardens = ref.read(getAllGardenUCProvider);
    final result = await getAllGardens.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingGardens: false,
        errLoadingGardens: failure.message,
      ),
      (gardens) =>
          state = state.copyWith(isLoadingGardens: false, gardens: gardens),
    );
  }

  Future<void> getGardenById({required String id}) async {
    state = state.copyWith(
      isLoadingGarden: true,
      errLoadingGarden: null,
      garden: () => null,
    );

    final getGardenById = ref.read(getGardenByIdUCProvider);
    final result = await getGardenById.call(GardenParams(id: id));

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingGarden: false,
        errLoadingGarden: failure.message,
      ),
      (garden) =>
          state = state.copyWith(isLoadingGarden: false, garden: () => garden),
    );
  }

  Future<void> createGarden(GardenEntity garden) async {
    state = state.copyWith(isCreatingGarden: true, errCreatingGarden: null);

    final createGarden = ref.read(createGardenUCProvider);
    final result = await createGarden.call(garden);

    result.fold(
      (failure) => state = state.copyWith(
        isCreatingGarden: false,
        errCreatingGarden: failure.message,
      ),
      (createdGarden) => state = state.copyWith(
        isCreatingGarden: false,
        responseMsg: 'Garden created successfully',
      ),
    );
  }

  Future<void> editGarden(GardenEntity garden) async {
    state = state.copyWith(isEditingGarden: true, errEditingGarden: null);

    final editGarden = ref.read(editGardenUCProvider);
    final result = await editGarden.call(garden);

    result.fold(
      (failure) => state = state.copyWith(
        isEditingGarden: false,
        errEditingGarden: failure.message,
      ),
      (editedGarden) => state = state.copyWith(
        isEditingGarden: false,
        responseMsg: 'Garden edited successfully',
      ),
    );
  }
}

// Auth provider
final gardenProvider = NotifierProvider<GardenNotifier, GardenState>(
  GardenNotifier.new,
);
