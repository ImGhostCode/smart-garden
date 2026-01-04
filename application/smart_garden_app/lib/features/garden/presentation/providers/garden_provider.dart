import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/garden_entity.dart';
import '../../domain/usecases/get_all_gardens.dart';
import '../../domain/usecases/get_garden_by_id.dart';
import '../../domain/usecases/send_garden_action.dart';
import '../../providers/garden_providers.dart';

class GardenState {
  final bool isLoadingGardens;
  final List<GardenEntity> gardens;
  final String errLoadingGardens;

  final bool isLoadingGarden;
  final GardenEntity? garden;
  final String errLoadingGarden;

  final bool isCreatingGarden;
  final String errCreatingGarden;

  final bool isEditingGarden;
  final String errEditingGarden;

  final bool isDeletingGarden;
  final String errDeletingGarden;

  final bool isSendingAction;
  final String errSendingAction;

  final String? responseMsg;

  const GardenState({
    this.isLoadingGardens = false,
    this.isLoadingGarden = false,
    this.isCreatingGarden = false,
    this.isEditingGarden = false,
    this.isDeletingGarden = false,
    this.isSendingAction = false,
    this.gardens = const [],
    this.garden,
    this.responseMsg,
    this.errLoadingGardens = "",
    this.errLoadingGarden = "",
    this.errCreatingGarden = "",
    this.errEditingGarden = "",
    this.errDeletingGarden = "",
    this.errSendingAction = "",
  });

  GardenState copyWith({
    bool? isLoadingGardens,
    bool? isLoadingGarden,
    bool? isCreatingGarden,
    bool? isEditingGarden,
    bool? isDeletingGarden,
    bool? isSendingAction,
    List<GardenEntity>? gardens,
    GardenEntity? Function()? garden,
    String? responseMsg,
    String? errLoadingGardens,
    String? errLoadingGarden,
    String? errCreatingGarden,
    String? errEditingGarden,
    String? errDeletingGarden,
    String? errSendingAction,
  }) {
    return GardenState(
      isLoadingGardens: isLoadingGardens ?? this.isLoadingGardens,
      isLoadingGarden: isLoadingGarden ?? this.isLoadingGarden,
      isCreatingGarden: isCreatingGarden ?? this.isCreatingGarden,
      isEditingGarden: isEditingGarden ?? this.isEditingGarden,
      isDeletingGarden: isDeletingGarden ?? this.isDeletingGarden,
      isSendingAction: isSendingAction ?? this.isSendingAction,
      gardens: gardens ?? this.gardens,
      garden: garden != null ? garden() : this.garden,
      errLoadingGardens: errLoadingGardens ?? this.errLoadingGardens,
      errLoadingGarden: errLoadingGarden ?? this.errLoadingGarden,
      errCreatingGarden: errCreatingGarden ?? this.errCreatingGarden,
      errEditingGarden: errEditingGarden ?? this.errEditingGarden,
      errDeletingGarden: errDeletingGarden ?? this.errDeletingGarden,
      errSendingAction: errSendingAction ?? this.errSendingAction,
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
      errLoadingGardens: '',
      gardens: [],
    );

    final getAllGardens = ref.read(getAllGardenUCProvider);
    final result = await getAllGardens.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingGardens: false,
        errLoadingGardens: failure.message,
      ),
      (response) => state = state.copyWith(
        isLoadingGardens: false,
        gardens: response.data,
      ),
    );
  }

  Future<void> getGardenById({required String id}) async {
    state = state.copyWith(
      isLoadingGarden: true,
      errLoadingGarden: '',
      garden: () => null,
    );

    final getGardenById = ref.read(getGardenByIdUCProvider);
    final result = await getGardenById.call(GardenParams(id: id));

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingGarden: false,
        errLoadingGarden: failure.message,
      ),
      (response) => state = state.copyWith(
        isLoadingGarden: false,
        garden: () => response.data,
      ),
    );
  }

  Future<void> createGarden(GardenEntity garden) async {
    state = state.copyWith(isCreatingGarden: true, errCreatingGarden: '');

    final createGarden = ref.read(createGardenUCProvider);
    final result = await createGarden.call(garden);

    result.fold(
      (failure) => state = state.copyWith(
        isCreatingGarden: false,
        errCreatingGarden: failure.message,
      ),
      (response) => state = state.copyWith(
        isCreatingGarden: false,
        responseMsg: response.message,
      ),
    );
  }

  Future<void> editGarden(GardenEntity garden) async {
    state = state.copyWith(isEditingGarden: true, errEditingGarden: '');

    final editGarden = ref.read(editGardenUCProvider);
    final result = await editGarden.call(garden);

    result.fold(
      (failure) => state = state.copyWith(
        isEditingGarden: false,
        errEditingGarden: failure.message,
      ),
      (response) => state = state.copyWith(
        isEditingGarden: false,
        responseMsg: response.message,
      ),
    );
  }

  Future<void> deleteGarden(String id) async {
    state = state.copyWith(isDeletingGarden: true, errDeletingGarden: '');

    final deleteGarden = ref.read(deleteGardenUCProvider);
    final result = await deleteGarden.call(id);

    result.fold(
      (failure) => state = state.copyWith(
        isDeletingGarden: false,
        errDeletingGarden: failure.message,
      ),
      (response) => state = state.copyWith(
        isDeletingGarden: false,
        responseMsg: response.message,
      ),
    );
  }

  Future<void> sendGardenAction(GardenActionParams params) async {
    state = state.copyWith(isSendingAction: true, errSendingAction: '');

    final sendGardenAction = ref.read(sendGardenActionUCProvider);
    final result = await sendGardenAction.call(params);

    result.fold(
      (failure) => state = state.copyWith(
        isSendingAction: false,
        errSendingAction: failure.message,
      ),
      (response) => state = state.copyWith(
        isSendingAction: false,
        responseMsg: response.message,
      ),
    );
  }
}

// Auth provider
final gardenProvider = NotifierProvider<GardenNotifier, GardenState>(
  GardenNotifier.new,
);
