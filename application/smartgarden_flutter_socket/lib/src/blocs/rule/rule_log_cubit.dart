import 'package:flutter_bloc/flutter_bloc.dart';

class RuleLogCubit extends Cubit<List<Map<String, dynamic>>> {
  RuleLogCubit() : super([]);

  void addLog(Map<String, dynamic> log) {
    final updated = List<Map<String, dynamic>>.from(state)..insert(0, log);
    emit(updated.take(50).toList()); // giữ tối đa 50 log gần nhất
  }

  void clear() => emit([]);
}
