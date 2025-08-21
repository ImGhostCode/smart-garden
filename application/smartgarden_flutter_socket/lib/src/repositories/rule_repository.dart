import 'package:smartgarden_flutter/src/api/api_service.dart';
import '../models/rule_model.dart';

class RuleRepository {
  final ApiService apiService;
  RuleRepository(this.apiService);

  Future<List<AutomationRule>> fetchRules(int? nodeId) async {
    try {
      final rules = await apiService.getRules(nodeId);
      return rules;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<AutomationRule> createRule(Map<String, dynamic> payload) async {
    try {
      final res = await apiService.createRule(payload);
      return res;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<AutomationRule> updateRule(
      String id, Map<String, dynamic> payload) async {
    try {
      final res = await apiService.updateRule(id, payload);
      return res;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteRule(String id) async {
    try {
      await apiService.deleteRule(id);
    } catch (e) {
      throw Exception(e);
    }
  }
}
