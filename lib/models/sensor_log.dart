class SensorLog {
  final int? id;
  final int tripId;
  final DateTime timestamp;
  final int? rpm;
  final double? speed;
  final double? engineTemp;
  final double? throttlePos;
  final double? voltage;

  SensorLog({
    this.id,
    required this.tripId,
    required this.timestamp,
    this.rpm,
    this.speed,
    this.engineTemp,
    this.throttlePos,
    this.voltage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'timestamp': timestamp.toIso8601String(),
      'rpm': rpm,
      'speed': speed,
      'engine_temp': engineTemp,
      'throttle_pos': throttlePos,
      'voltage': voltage,
    };
  }

  factory SensorLog.fromMap(Map<String, dynamic> map) {
    return SensorLog(
      id: map['id'] as int,
      tripId: map['trip_id'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
      rpm: map['rpm'] as int?,
      speed: map['speed'] as double?,
      engineTemp: map['engine_temp'] as double?,
      throttlePos: map['throttle_pos'] as double?,
      voltage: map['voltage'] as double?,
    );
  }

  SensorLog copyWith({
    int? id,
    int? tripId,
    DateTime? timestamp,
    int? rpm,
    double? speed,
    double? engineTemp,
    double? throttlePos,
    double? voltage,
  }) {
    return SensorLog(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      timestamp: timestamp ?? this.timestamp,
      rpm: rpm ?? this.rpm,
      speed: speed ?? this.speed,
      engineTemp: engineTemp ?? this.engineTemp,
      throttlePos: throttlePos ?? this.throttlePos,
      voltage: voltage ?? this.voltage,
    );
  }

  @override
  String toString() {
    return 'RPM: ${rpm ?? "N/A"}, Speed: ${speed?.toStringAsFixed(1) ?? "N/A"} km/h';
  }
}
