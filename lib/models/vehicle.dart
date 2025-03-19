class Vehicle {
  final int? id;
  final String name;
  final String make;
  final String model;
  final int year;
  final String? vin;
  final DateTime createdAt;

  Vehicle({
    this.id,
    required this.name,
    required this.make,
    required this.model,
    required this.year,
    this.vin,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'make': make,
      'model': model,
      'year': year,
      'vin': vin,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int,
      name: map['name'] as String,
      make: map['make'] as String,
      model: map['model'] as String,
      year: map['year'] as int,
      vin: map['vin'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  String toString() {
    return '$year $make $model ($name)';
  }
}
