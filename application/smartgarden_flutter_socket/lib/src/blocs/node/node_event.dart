part of 'node_bloc.dart';

abstract class NodeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNodes extends NodeEvent {}

class SelectNode extends NodeEvent {
  final int nodeId;
  SelectNode(this.nodeId);
}

class RefreshLatest extends NodeEvent {}

class LoadHistory extends NodeEvent {}

class LoadCommands extends NodeEvent {
  final int? nodeId;
  LoadCommands({this.nodeId});
}

class PumpControl extends NodeEvent {
  final int nodeId;
  final String command; // 'ON' or 'OFF'
  final bool lock;
  final int? expireSec;

  PumpControl({
    required this.nodeId,
    required this.command,
    this.lock = false,
    this.expireSec,
  });
}
