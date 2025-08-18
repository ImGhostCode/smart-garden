import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../services/socket_service.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';

class CommandsPage extends StatefulWidget {
  final ApiService api;
  final SocketService socket;
  const CommandsPage({super.key, required this.api, required this.socket});

  @override
  State<CommandsPage> createState() => _CommandsPageState();
}

class _CommandsPageState extends State<CommandsPage> {
  List<CommandLog> logs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    widget.socket.onCommand((data) {
      // incoming realtime command log (server should emit 'command' when new command logged)
      final log = CommandLog.fromJson(Map<String, dynamic>.from(data));
      setState(() {
        logs.insert(0, log);
      });
    });
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final res = await widget.api.getCommands(limit: 200);
      setState(() {
        logs = res;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Load error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Commands')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: logs.length,
                itemBuilder: (context, i) {
                  final l = logs[i];
                  return Card(
                    child: ListTile(
                      title:
                          Text('Node ${l.nodeId} • ${l.command} • ${l.status}'),
                      subtitle: Text('${l.topic} • ${df.format(l.createdAt)}'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
