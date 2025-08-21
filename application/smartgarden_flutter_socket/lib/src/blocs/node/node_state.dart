part of 'node_bloc.dart';

class NodeState extends Equatable {
  final bool loading;
  final List<NodeMeta> nodes;
  final int? selectedNodeId;
  final SensorReading? latest;
  final List<SensorReading> history;
  final bool historyLoading;
  final String? error;

  const NodeState({
    required this.loading,
    required this.nodes,
    required this.selectedNodeId,
    required this.latest,
    required this.history,
    required this.historyLoading,
    required this.error,
  });

  factory NodeState.initial() => const NodeState(
        loading: false,
        nodes: [],
        selectedNodeId: null,
        latest: null,
        history: [],
        historyLoading: false,
        error: null,
      );

  NodeState copyWith({
    bool? loading,
    List<NodeMeta>? nodes,
    int? selectedNodeId,
    SensorReading? latest,
    List<SensorReading>? history,
    bool? historyLoading,
    String? error,
  }) =>
      NodeState(
        loading: loading ?? this.loading,
        nodes: nodes ?? this.nodes,
        selectedNodeId: selectedNodeId ?? this.selectedNodeId,
        latest: latest ?? this.latest,
        history: history ?? this.history,
        historyLoading: historyLoading ?? this.historyLoading,
        error: error,
      );

  @override
  List<Object?> get props =>
      [loading, nodes, selectedNodeId, latest, history, historyLoading, error];
}
