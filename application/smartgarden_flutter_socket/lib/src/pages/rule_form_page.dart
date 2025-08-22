import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartgarden_flutter/src/blocs/node/node_bloc.dart';
import 'package:smartgarden_flutter/src/blocs/rule/rule_event.dart';
import 'package:smartgarden_flutter/src/blocs/rule/rule_state.dart';
import '../blocs/rule/rule_bloc.dart';

class RuleFormPage extends StatefulWidget {
  final Map<String, dynamic>? initial; // nếu null => create, else => edit
  const RuleFormPage({super.key, this.initial});

  @override
  State<RuleFormPage> createState() => _RuleFormPageState();
}

class _RuleFormPageState extends State<RuleFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;
  late TextEditingController _durationCtrl;
  late TextEditingController _cooldownCtrl;
  late TextEditingController _dailyCtrl;
  String _type = "soil_threshold";
  bool _enabled = true;
  int? _selectedNode;

  List<Map<String, String>> _timeWindows = [];

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    _selectedNode = init?["node_id"];
    _nameCtrl = TextEditingController(text: init?["name"] ?? "");
    _minCtrl = TextEditingController(text: init?["min"]?.toString() ?? "");
    _maxCtrl = TextEditingController(text: init?["max"]?.toString() ?? "");
    _durationCtrl =
        TextEditingController(text: init?["durationSec"]?.toString() ?? "20");
    _cooldownCtrl =
        TextEditingController(text: init?["cooldownSec"]?.toString() ?? "300");
    _dailyCtrl = TextEditingController(
        text: init?["maxDailyRuntimeSec"]?.toString() ?? "1800");
    _type = init?["type"] ?? "soil_threshold";
    _enabled = init?["enabled"] ?? true;
    _timeWindows = List<Map<String, String>>.from(init?["timeWindows"] ?? []);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final payload = {
      "name": _nameCtrl.text,
      "node_id": _selectedNode,
      "type": _type,
      "min": int.tryParse(_minCtrl.text),
      "max": int.tryParse(_maxCtrl.text),
      "action": "pump_on",
      "durationSec": int.parse(_durationCtrl.text),
      "enabled": _enabled,
      "timeWindows": _timeWindows,
      "cooldownSec": int.parse(_cooldownCtrl.text),
      "maxDailyRuntimeSec": int.parse(_dailyCtrl.text),
    };

    final bloc = context.read<RuleBloc>();
    if (widget.initial == null) {
      bloc.add(AddRule(payload));
    } else {
      bloc.add(UpdateRule(widget.initial!["_id"], payload));
    }
    // Navigator.pop(context);
  }

  void _addTimeWindow() async {
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();
    final res = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Time Window"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: startCtrl,
                decoration: const InputDecoration(labelText: "Start (HH:mm)")),
            TextField(
                controller: endCtrl,
                decoration: const InputDecoration(labelText: "End (HH:mm)")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                if (startCtrl.text.isNotEmpty && endCtrl.text.isNotEmpty) {
                  Navigator.pop(
                      ctx, {"start": startCtrl.text, "end": endCtrl.text});
                }
              },
              child: const Text("Add")),
        ],
      ),
    );
    if (res != null) {
      setState(() => _timeWindows.add(res));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    final nodes = context.select<NodeBloc, List<int>>(
        (b) => b.state.nodes.map((n) => n.nodeId).toList());
    if (_selectedNode == null && nodes.isNotEmpty) {
      _selectedNode = nodes.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Rule" : "New Rule"),
        actions: [
          DropdownButton<int>(
            value: _selectedNode ?? nodes.first,
            items: nodes.map((n) {
              return DropdownMenuItem<int>(
                value: n,
                child: Text("Node $n"),
              );
            }).toList(),
            onChanged: (n) => setState(() => _selectedNode = n!),
            // decoration: const InputDecoration(labelText: "Type")
          ),
        ],
      ),
      body: BlocListener<RuleBloc, RuleState>(
        listenWhen: (previous, current) {
          return current is RuleAdded ||
              current is RuleUpdated ||
              current is RuleAddingError ||
              current is RuleUpdatingError;
        },
        listener: (context, state) {
          if (state is RuleAdded || state is RuleUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Operation success!")),
            );
            Navigator.pop(context);
          } else if (state is RuleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: ${state.message}")),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: "Name")),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  items: const [
                    DropdownMenuItem(
                        value: "soil_threshold", child: Text("Soil Moisture")),
                    DropdownMenuItem(
                        value: "humidity_threshold", child: Text("Humidity")),
                    DropdownMenuItem(
                        value: "temperature_threshold",
                        child: Text("Temperature")),
                  ],
                  onChanged: (v) => setState(() => _type = v!),
                  decoration: const InputDecoration(labelText: "Type"),
                ),
                TextFormField(
                    controller: _minCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: "Min Threshold")),
                TextFormField(
                    controller: _maxCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: "Max Threshold")),
                TextFormField(
                    controller: _durationCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: "Duration (sec)")),
                TextFormField(
                    controller: _cooldownCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: "Cooldown (sec)")),
                TextFormField(
                    controller: _dailyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: "Max Daily Runtime (sec)")),
                SwitchListTile(
                  value: _enabled,
                  onChanged: (v) => setState(() => _enabled = v),
                  title: const Text("Enabled"),
                ),
                const SizedBox(height: 10),
                Text("Time Windows",
                    style: Theme.of(context).textTheme.titleSmall),
                Column(
                  children: _timeWindows
                      .map((w) => ListTile(
                            title: Text("${w["start"]} - ${w["end"]}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() => _timeWindows.remove(w));
                              },
                            ),
                          ))
                      .toList(),
                ),
                TextButton.icon(
                  onPressed: _addTimeWindow,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Window"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: context.read<RuleBloc>().state is RuleAdding ||
                          context.read<RuleBloc>().state is RuleUpdating
                      ? null
                      : _save,
                  child: Text(isEdit ? "Update" : "Create"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
