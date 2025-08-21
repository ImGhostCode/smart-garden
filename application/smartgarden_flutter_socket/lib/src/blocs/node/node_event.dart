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
class SendPump extends NodeEvent {
  final String command; // 'ON' or 'OFF'
  SendPump(this.command);
}
