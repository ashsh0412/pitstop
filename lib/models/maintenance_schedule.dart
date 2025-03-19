class MaintenanceSchedule {
  final int? id;
  final int vehicleId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int? dueMileage;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  MaintenanceSchedule({
    this.id,
    required this.vehicleId,
    required this.title,
    this.description,
    this.dueDate,
    this.dueMileage,
    this.isCompleted = false,
    this.completedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MaintenanceSchedule.fromMap(Map<String, dynamic> map) {
    return MaintenanceSchedule(
      id: map['id'] as int?,
      vehicleId: map['vehicle_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : null,
      dueMileage: map['due_mileage'] as int?,
      isCompleted: (map['is_completed'] as int) == 1,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'vehicle_id': vehicleId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'due_mileage': dueMileage,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  MaintenanceSchedule copyWith({
    int? id,
    int? vehicleId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? dueMileage,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return MaintenanceSchedule(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueMileage: dueMileage ?? this.dueMileage,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return '$title (${isCompleted ? "완료" : "미완료"})';
  }
}
