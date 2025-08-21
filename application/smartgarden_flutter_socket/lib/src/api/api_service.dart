import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartgarden_flutter/src/models/rule_model.dart';
import '../models/models.dart';

class ApiService {
  final String baseUrl;
  ApiService({required this.baseUrl});

  Uri _u(String path, [Map<String, dynamic>? query]) =>
      Uri.parse('$baseUrl/api$path')
          .replace(queryParameters: query?.map((k, v) => MapEntry(k, '$v')));

  Future<List<NodeMeta>> getNodes() async {
    final res = await http.get(_u('/nodes'));
    if (res.statusCode != 200) throw Exception('Failed to load nodes');
    final data = jsonDecode(res.body) as List;
    return data.map((j) => NodeMeta.fromJson(j)).toList();
  }

  Future<SensorReading?> getLatest(int nodeId) async {
    final res = await http.get(_u('/nodes/$nodeId/latest'));
    if (res.statusCode != 200) throw Exception('Failed to load latest reading');
    if (res.body.isEmpty) return null;
    final data = jsonDecode(res.body);
    if (data is Map && data.isEmpty) return null;
    return SensorReading.fromJson(data);
  }

  Future<List<SensorReading>> getReadings({
    required int nodeId,
    DateTime? from,
    DateTime? to,
    int limit = 500,
  }) async {
    final q = <String, dynamic>{
      'nodeId': nodeId,
      'limit': limit,
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
    };
    final res = await http.get(_u('/readings', q));
    if (res.statusCode != 200) throw Exception('Failed to load readings');
    final data = jsonDecode(res.body) as List;
    return data.map((j) => SensorReading.fromJson(j)).toList();
  }

  Future<CommandLog> sendPump(int nodeId, String command) async {
    final res = await http.post(
      _u('/pump/$nodeId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'command': command}),
    );
    if (res.statusCode != 200) throw Exception('Failed to send command');
    final data = jsonDecode(res.body);
    return CommandLog.fromJson(data['log']);
  }

  Future<List<CommandLog>> getCommands({int? nodeId, int limit = 100}) async {
    final q = <String, dynamic>{
      'limit': limit,
      if (nodeId != null) 'nodeId': nodeId
    };
    final res = await http.get(_u('/commands', q));
    if (res.statusCode != 200) throw Exception('Failed to load commands');
    final data = jsonDecode(res.body) as List;
    return data.map((j) => CommandLog.fromJson(j)).toList();
  }

  Future<List<AutomationRule>> getRules(int? nodeId) async {
    final res =
        await http.get(_u('/rules', {if (nodeId != null) 'nodeId': nodeId}));
    if (res.statusCode != 200) throw Exception('Failed to load rules');
    final data = jsonDecode(res.body) as List;
    return data.map((j) => AutomationRule.fromJson(j)).toList();
  }

  Future<AutomationRule> createRule(Map<String, dynamic> payload) async {
    final res = await http.post(
      _u('/rules'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) throw Exception('Failed to create rule');
    return AutomationRule.fromJson(jsonDecode(res.body));
  }

  Future<AutomationRule> updateRule(
      String id, Map<String, dynamic> payload) async {
    final res = await http.put(
      _u('/rules/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) throw Exception('Failed to update rule');
    return AutomationRule.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteRule(String id) async {
    final res = await http.delete(_u('/rules/$id'));
    if (res.statusCode != 200) throw Exception('Failed to delete rule');
  }
}
