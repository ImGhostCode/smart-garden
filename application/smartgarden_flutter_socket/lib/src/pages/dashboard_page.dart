import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../api/api_service.dart';
import '../bloc/node_bloc.dart';
import '../models/models.dart';
import '../widgets/reading_chart.dart';
import '../services/socket_service.dart';

class DashboardPage extends StatefulWidget {
  final ApiService api;
  final SocketService socket;
  const DashboardPage({super.key, required this.api, required this.socket});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // final bloc = context.read<NodeBloc>();
    // Remove the delay from the stream listener; use a Timer for periodic refresh if needed.
    // bloc.stream.listen((state) {
    //   if (state.selectedNodeId != null &&
    //       state.history.isEmpty &&
    //       !state.historyLoading) {
    //     bloc
    //       ..add(RefreshLatest())
    //       ..add(LoadHistory());
    //   }
    // });

    widget.socket.onReading((data) {
      // data should contain node_id and sensor fields
      final nid = data['node_id'];
      final cur = context.read<NodeBloc>().state;
      if (cur.selectedNodeId == nid) {
        // force refresh latest
        context.read<NodeBloc>().add(RefreshLatest());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('SmartGarden Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: BlocBuilder<NodeBloc, NodeState>(
          builder: (context, state) {
            if (state.loading && state.nodes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Node:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: state.selectedNodeId,
                      items: state.nodes
                          .map((n) => DropdownMenuItem(
                              value: n.nodeId,
                              child: Text(
                                  'Node ${n.nodeId} ${n.name.isNotEmpty ? "(${n.name})" : ""}')))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          context.read<NodeBloc>()
                            ..add(SelectNode(v))
                            ..add(RefreshLatest())
                            ..add(LoadHistory());
                        }
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        context.read<NodeBloc>()
                          ..add(RefreshLatest())
                          ..add(LoadHistory());
                      },
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    )
                  ],
                ),
                const SizedBox(height: 8),
                if (state.latest != null)
                  _LatestCards(reading: state.latest!, df: df),
                const SizedBox(height: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Last 24h',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Expanded(
                              child: ReadingChart(readings: state.history)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: state.selectedNodeId == null
                            ? null
                            : () =>
                                context.read<NodeBloc>().add(SendPump('ON')),
                        icon: const Icon(Icons.water_drop),
                        label: const Text('PUMP ON'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: state.selectedNodeId == null
                            ? null
                            : () =>
                                context.read<NodeBloc>().add(SendPump('OFF')),
                        icon: const Icon(Icons.water_drop_outlined),
                        label: const Text('PUMP OFF'),
                      ),
                    ),
                  ],
                ),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(state.error!,
                        style: const TextStyle(color: Colors.red)),
                  )
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LatestCards extends StatelessWidget {
  final SensorReading reading;
  final DateFormat df;
  const _LatestCards({required this.reading, required this.df});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _metric(
            'Temperature',
            reading.temperature != null
                ? '${reading.temperature!.toStringAsFixed(1)} °C'
                : '--'),
        _metric(
            'Humidity',
            reading.humidity != null
                ? '${reading.humidity!.toStringAsFixed(1)} %'
                : '--'),
        _metric('LDR', reading.ldr?.toString() ?? '--'),
        _metric('Soil', reading.soil?.toString() ?? '--'),
        _metric('Updated', df.format(reading.createdAt)),
      ],
    );
  }

  Widget _metric(String title, String value) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
