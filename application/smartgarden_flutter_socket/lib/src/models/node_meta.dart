class NodeMeta {
  final int nodeId;
  final String name;
  final String location;
  final DateTime? lastSeenAt;

  NodeMeta({
    required this.nodeId,
    required this.name,
    required this.location,
    this.lastSeenAt,
  });

  factory NodeMeta.fromJson(Map<String, dynamic> j) => NodeMeta(
        nodeId: (j['node_id'] as num).toInt(),
        name: (j['name'] ?? '') as String,
        location: (j['location'] ?? '') as String,
        lastSeenAt: j['lastSeenAt'] != null ? DateTime.parse(j['lastSeenAt'] as String) : null,
      );
}
