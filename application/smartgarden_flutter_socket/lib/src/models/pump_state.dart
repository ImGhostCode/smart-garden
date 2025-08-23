class PumpStateModel {
  final int nodeId;
  final String state; // "ON" | "OFF"
  final String source; // "manual" | "auto"
  final DateTime? expiresAt;
  final bool manualLock;

  PumpStateModel({
    required this.nodeId,
    required this.state,
    required this.source,
    this.expiresAt,
    this.manualLock = false,
  });

  factory PumpStateModel.fromJson(Map<String, dynamic> j) => PumpStateModel(
        nodeId: j["node_id"],
        state: j["state"],
        source: j["source"] ?? "manual",
        expiresAt:
            j["expiresAt"] != null ? DateTime.parse(j["expiresAt"]) : null,
        manualLock: j["manualLock"] == true,
      );
}
