import 'package:smartgarden_flutter/src/models/rule_model.dart';

abstract class RuleState {}

class RuleInitial extends RuleState {}

class RuleLoading extends RuleState {}

class RuleLoaded extends RuleState {
  final List<AutomationRule> rules;
  RuleLoaded(this.rules);
}

class RuleError extends RuleState {
  final String message;
  RuleError(this.message);
}

class RuleAdding extends RuleState {
  RuleAdding();
}

class RuleAdded extends RuleState {
  final AutomationRule rule;
  RuleAdded(this.rule);
}

class RuleAddingError extends RuleError {
  RuleAddingError(super.message);
}

class RuleUpdating extends RuleState {
  RuleUpdating();
}

class RuleUpdated extends RuleState {
  final AutomationRule rule;
  RuleUpdated(this.rule);
}

class RuleUpdatingError extends RuleError {
  RuleUpdatingError(super.message);
}

class RuleDeleting extends RuleState {
  RuleDeleting();
}

class RuleDeleted extends RuleState {
  RuleDeleted();
}

class RuleDeletingError extends RuleError {
  RuleDeletingError(super.message);
}
