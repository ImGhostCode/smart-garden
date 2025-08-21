import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smartgarden_flutter/src/api/api_service.dart';
import 'package:smartgarden_flutter/src/models/models.dart';

part 'node_event.dart';
part 'node_state.dart';

class NodeBloc extends Bloc<NodeEvent, NodeState> {
  final ApiService api;
  NodeBloc(this.api) : super(NodeState.initial()) {
    on<LoadNodes>((event, emit) async {
      emit(state.copyWith(loading: true));
      try {
        final nodes = await api.getNodes();
        final selected = nodes.isNotEmpty ? nodes.first.nodeId : null;
        emit(state.copyWith(
            loading: false, nodes: nodes, selectedNodeId: selected));
        add(RefreshLatest());
        add(LoadHistory());
      } catch (e) {
        emit(state.copyWith(loading: false, error: e.toString()));
      }
    });

    on<SelectNode>((event, emit) async {
      emit(state.copyWith(selectedNodeId: event.nodeId));
    });

    on<RefreshLatest>((event, emit) async {
      if (state.selectedNodeId == null) return;
      try {
        final latest = await api.getLatest(state.selectedNodeId!);
        emit(state.copyWith(latest: latest));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });

    on<LoadHistory>((event, emit) async {
      if (state.selectedNodeId == null) return;
      emit(state.copyWith(historyLoading: true));
      try {
        final to = DateTime.now();
        final from = to.subtract(const Duration(hours: 24));
        final hist = await api.getReadings(
            nodeId: state.selectedNodeId!, from: from, to: to, limit: 1000);
        emit(state.copyWith(historyLoading: false, history: hist));
      } catch (e) {
        emit(state.copyWith(historyLoading: false, error: e.toString()));
      }
    });

    on<SendPump>((event, emit) async {
      if (state.selectedNodeId == null) return;
      try {
        await api.sendPump(state.selectedNodeId!, event.command);
        add(RefreshLatest());
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
  }
}
