class SensorReading {
  final int nodeId;
  final double? temperature;
  final double? humidity;
  final int? ldr;
  final int? soil;
  final DateTime createdAt;

  SensorReading({
    required this.nodeId,
    this.temperature,
    this.humidity,
    this.ldr,
    this.soil,
    required this.createdAt,
  });

  factory SensorReading.fromJson(Map<String, dynamic> j) => SensorReading(
        nodeId: (j['node_id'] as num).toInt(),
        temperature: (j['temperature'] as num?)?.toDouble(),
        humidity: (j['humidity'] as num?)?.toDouble(),
        ldr: (j['ldr'] as num?)?.toInt(),
        soil: (j['soil'] as num?)?.toInt(),
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}
