class TripLog {
  final int? id;
  final int vehicleId;
  final DateTime startTime;
  final DateTime? endTime;
  final double startMileage;
  final double? endMileage;
  final double? averageSpeed;
  final double? maxSpeed;
  final double? fuelConsumed;

  TripLog({
    this.id,
    required this.vehicleId,
    required this.startTime,
    this.endTime,
    required this.startMileage,
    this.endMileage,
    this.averageSpeed,
    this.maxSpeed,
    this.fuelConsumed,
  });

  bool get isActive => endTime == null;

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  double? get distance {
    if (endMileage == null) return null;
    return endMileage! - startMileage;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'start_mileage': startMileage,
      'end_mileage': endMileage,
      'average_speed': averageSpeed,
      'max_speed': maxSpeed,
      'fuel_consumed': fuelConsumed,
    };
  }

  factory TripLog.fromMap(Map<String, dynamic> map) {
    return TripLog(
      id: map['id'] as int,
      vehicleId: map['vehicle_id'] as int,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] != null
          ? DateTime.parse(map['end_time'] as String)
          : null,
      startMileage: map['start_mileage'] as double,
      endMileage: map['end_mileage'] as double?,
      averageSpeed: map['average_speed'] as double?,
      maxSpeed: map['max_speed'] as double?,
      fuelConsumed: map['fuel_consumed'] as double?,
    );
  }

  TripLog copyWith({
    int? id,
    int? vehicleId,
    DateTime? startTime,
    DateTime? endTime,
    double? startMileage,
    double? endMileage,
    double? averageSpeed,
    double? maxSpeed,
    double? fuelConsumed,
  }) {
    return TripLog(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startMileage: startMileage ?? this.startMileage,
      endMileage: endMileage ?? this.endMileage,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      fuelConsumed: fuelConsumed ?? this.fuelConsumed,
    );
  }

  @override
  String toString() {
    final formattedStart =
        '${startTime.year}-${startTime.month}-${startTime.day} ${startTime.hour}:${startTime.minute}';
    return isActive ? '주행 중 (시작: $formattedStart)' : '주행 완료 ($formattedStart)';
  }
}
