import 'dart:convert';
import 'package:http/http.dart' as http;
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
}
