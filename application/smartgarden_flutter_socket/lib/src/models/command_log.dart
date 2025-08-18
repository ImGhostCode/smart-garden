class CommandLog {
  final int nodeId;
  final String command;
  final String status;
  final String topic;
  final DateTime createdAt;

  CommandLog({
    required this.nodeId,
    required this.command,
    required this.status,
    required this.topic,
    required this.createdAt,
  });

  factory CommandLog.fromJson(Map<String, dynamic> j) => CommandLog(
        nodeId: (j['node_id'] as num).toInt(),
        command: j['command'] as String,
        status: j['status'] as String,
        topic: j['topic'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}
