import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/pump_state.dart';

class PumpStateCubit extends Cubit<Map<int, PumpStateModel>> {
  PumpStateCubit() : super({});

  void bootstrap(List<dynamic> items) {
    final map = <int, PumpStateModel>{};
    for (final it in items) {
      final m = PumpStateModel.fromJson(Map<String, dynamic>.from(it));
      map[m.nodeId] = m;
    }
    emit(map);
  }

  void updateFromSocket(Map<String, dynamic> data) {
    final m = PumpStateModel.fromJson(data);
    final next = Map<int, PumpStateModel>.from(state)..[m.nodeId] = m;
    emit(next);
  }
}
