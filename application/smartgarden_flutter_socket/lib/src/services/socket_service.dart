import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

typedef OnReading = void Function(Map<String, dynamic> data);
typedef OnCommand = void Function(Map<String, dynamic> data);
typedef OnAutomationAction = void Function(Map<String, dynamic> data);

class SocketService {
  final String baseUrl;
  IO.Socket? _socket;
  final _ready = Completer<void>();

  SocketService({required this.baseUrl}) {
    _init();
  }

  void _init() {
    // assume server exposes socket.io at same host (ws) without /api prefix
    final uri = baseUrl.replaceFirst(RegExp(r'^http'), 'ws');
    _socket = IO.io(uri, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket!.on('connect', (_) {
      print('[Socket] connected');
      if (!_ready.isCompleted) _ready.complete();
    });
    _socket!.on('disconnect', (_) => print('[Socket] disconnected'));
    _socket!.on('reading', (data) => print('[Socket] reading: $data'));
    _socket!.on('command', (data) => print('[Socket] command: $data'));
    _socket!.on('error', (err) => print('[Socket] error: $err'));
    _socket!.connect();
  }

  Future<void> ready() => _ready.future;

  void onReading(OnReading cb) {
    _socket?.on('reading', (d) => cb(Map<String, dynamic>.from(d as Map)));
  }

  void onCommand(OnCommand cb) {
    _socket?.on('command', (d) => cb(Map<String, dynamic>.from(d as Map)));
  }

  void onAutomationAction(OnAutomationAction cb) {
    _socket?.on(
        'automation_action', (d) => cb(Map<String, dynamic>.from(d as Map)));
  }

  void onPumpStateBootstrap(void Function(List<dynamic> data) cb) {
    _socket?.on('pump_state_bootstrap', (data) {
      if (data is List) cb(List<dynamic>.from(data));
    });
  }

  void onPumpState(void Function(Map<String, dynamic> data) cb) {
    _socket?.on('pump_state', (data) {
      if (data is Map<String, dynamic>) cb(data);
    });
  }

  void dispose() {
    _socket?.dispose();
  }
}
