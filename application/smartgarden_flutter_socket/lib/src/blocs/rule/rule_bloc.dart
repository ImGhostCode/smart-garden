import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartgarden_flutter/src/blocs/rule/rule_event.dart';
import 'package:smartgarden_flutter/src/blocs/rule/rule_state.dart';
import '../../repositories/rule_repository.dart';

class RuleBloc extends Bloc<RuleEvent, RuleState> {
  final RuleRepository repo;

  RuleBloc(this.repo) : super(RuleInitial()) {
    on<LoadRules>((event, emit) async {
      emit(RuleLoading());
      try {
        final rules = await repo.fetchRules(event.nodeId);
        emit(RuleLoaded(rules));
      } catch (e) {
        emit(RuleError(e.toString()));
      }
    });

    on<AddRule>((event, emit) async {
      emit(RuleAdding());
      try {
        final added = await repo.createRule(event.payload);
        emit(RuleAdded(added));
        add(LoadRules(null)); // Refresh rules after adding
      } catch (e) {
        emit(RuleAddingError(e.toString()));
      }
    });

    on<DeleteRule>((event, emit) async {
      emit(RuleDeleting());
      try {
        await repo.deleteRule(event.id);
        emit(RuleDeleted());
        add(LoadRules(null)); // Refresh rules after deletion
      } catch (e) {
        emit(RuleDeletingError(e.toString()));
      }
    });

    on<UpdateRule>((event, emit) async {
      emit(RuleUpdating());
      try {
        final updated = await repo.updateRule(event.id, event.payload);
        emit(RuleUpdated(updated));
        add(LoadRules(null)); // Refresh rules after updating
      } catch (e) {
        emit(RuleUpdatingError(e.toString()));
      }
    });
  }
}
