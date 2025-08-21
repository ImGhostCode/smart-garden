abstract class RuleEvent {}

class LoadRules extends RuleEvent {
  final int? nodeId;
  LoadRules(this.nodeId);
}

class AddRule extends RuleEvent {
  final Map<String, dynamic> payload;
  AddRule(this.payload);
}

class DeleteRule extends RuleEvent {
  final String id;
  DeleteRule(this.id);
}

class UpdateRule extends RuleEvent {
  final String id;
  final Map<String, dynamic> payload;
  UpdateRule(this.id, this.payload);
}
