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
      if (state is RuleLoaded) {
        try {
          await repo.createRule(event.payload);
          final rules = await repo.fetchRules(null);
          emit(RuleLoaded(rules));
        } catch (e) {
          emit(RuleError(e.toString()));
        }
      }
    });

    on<DeleteRule>((event, emit) async {
      if (state is RuleLoaded) {
        try {
          await repo.deleteRule(event.id);
          final rules = await repo.fetchRules(null);
          emit(RuleLoaded(rules));
        } catch (e) {
          emit(RuleError(e.toString()));
        }
      }
    });

    on<UpdateRule>((event, emit) async {
      if (state is RuleLoaded) {
        try {
          await repo.updateRule(event.id, event.payload);
          final rules = await repo.fetchRules(null);
          emit(RuleLoaded(rules));
        } catch (e) {
          emit(RuleError(e.toString()));
        }
      }
    });
  }
}
