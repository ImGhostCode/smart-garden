import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartgarden_flutter/src/blocs/rule/rule_log_cubit.dart';
import 'package:smartgarden_flutter/src/pages/rule_form_page.dart';
import 'package:smartgarden_flutter/src/services/socket_service.dart';
import '../blocs/rule/rule_bloc.dart';
import '../blocs/rule/rule_event.dart';
import '../blocs/rule/rule_state.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RulesPage extends StatefulWidget {
  final SocketService socket;
  const RulesPage({super.key, required this.socket});

  @override
  State<RulesPage> createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage> {
  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<RuleLogCubit>();
    widget.socket.onAutomationAction((data) {
      cubit.addLog(Map<String, dynamic>.from(data));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Automation Rules")),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<RuleBloc>().add(LoadRules(null));
        },
        child: Column(
          children: [
            Expanded(
              child: BlocListener<RuleBloc, RuleState>(
                listenWhen: (previous, current) {
                  return current is RuleDeleted || current is RuleDeletingError;
                },
                listener: (context, state) {
                  if (state is RuleDeleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Operation success!")),
                    );
                  } else if (state is RuleDeletingError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${state.message}")),
                    );
                  }
                },
                child: BlocBuilder<RuleBloc, RuleState>(
                  buildWhen: (previous, current) {
                    return current is RuleLoading ||
                        current is RuleLoaded ||
                        current is RuleError;
                  },
                  builder: (context, state) {
                    if (state is RuleLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is RuleLoaded) {
                      if (state.rules.isEmpty) {
                        return const Center(child: Text("No rules"));
                      }
                      return ListView.builder(
                        itemCount: state.rules.length,
                        itemBuilder: (context, index) {
                          final rule = state.rules[index];
                          return ListTile(
                            title: Text(
                                rule.name.isNotEmpty ? rule.name : rule.type),
                            subtitle: Text(
                                "Min:${rule.min}, Max:${rule.max}, Duration:${rule.durationSec}s"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RuleFormPage(initial: {
                                          "_id": rule.id,
                                          "name": rule.name,
                                          "node_id": rule.nodeId,
                                          "type": rule.type,
                                          "min": rule.min,
                                          "max": rule.max,
                                          "durationSec": rule.durationSec,
                                          "enabled": rule.enabled,
                                          "timeWindows": rule.timeWindows,
                                          "cooldownSec": rule.cooldownSec,
                                          "maxDailyRuntimeSec":
                                              rule.maxDailyRuntimeSec,
                                        }),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    context
                                        .read<RuleBloc>()
                                        .add(DeleteRule(rule.id));
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else if (state is RuleError) {
                      return Center(child: Text("Error: ${state.message}"));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: BlocBuilder<RuleLogCubit, List<Map<String, dynamic>>>(
                builder: (context, logs) {
                  return ListView(
                    children: logs.map((log) {
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.bolt, color: Colors.green),
                        title:
                            Text("Rule ${log["ruleName"]} → ${log["command"]}"),
                        subtitle: Text(
                            "Node ${log["node_id"]} at ${log["createdAt"]}"),
                      );
                    }).toList(),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RuleFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
