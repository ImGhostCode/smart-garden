class AutomationRule {
  final String id;
  final int nodeId;
  final String name;
  final String type; // "soil_threshold", ...
  final int? min;
  final int? max;
  final String action;
  final int durationSec;
  final bool enabled;
  final List<Map<String, String>> timeWindows;
  final int cooldownSec;
  final int maxDailyRuntimeSec;

  AutomationRule({
    required this.id,
    required this.nodeId,
    required this.name,
    required this.type,
    this.min,
    this.max,
    required this.action,
    required this.durationSec,
    required this.enabled,
    required this.timeWindows,
    required this.cooldownSec,
    required this.maxDailyRuntimeSec,
  });

  factory AutomationRule.fromJson(Map<String, dynamic> json) {
    return AutomationRule(
      id: json["_id"],
      nodeId: json["node_id"],
      name: json["name"] ?? "",
      type: json["type"],
      min: json["min"],
      max: json["max"],
      action: json["action"],
      durationSec: json["durationSec"],
      enabled: json["enabled"],
      timeWindows: (json["timeWindows"] as List<dynamic>?)
              ?.map((e) => {
                    "start": e["start"]?.toString() ?? "",
                    "end": e["end"]?.toString() ?? ""
                  })
              .toList() ??
          [],
      cooldownSec: json["cooldownSec"] ?? 0,
      maxDailyRuntimeSec: json["maxDailyRuntimeSec"] ?? 0,
    );
  }
}
