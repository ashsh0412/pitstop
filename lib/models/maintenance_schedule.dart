class MaintenanceSchedule {
  final String id;
  final String vehicleId;
  final String title;
  final DateTime dueDate;
  final bool isCompleted;
  final String description;

  MaintenanceSchedule({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.dueDate,
    required this.isCompleted,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'description': description,
    };
  }

  factory MaintenanceSchedule.fromMap(Map<String, dynamic> map) {
    return MaintenanceSchedule(
      id: map['id'] as String,
      vehicleId: map['vehicleId'] as String,
      title: map['title'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      isCompleted: map['isCompleted'] as bool,
      description: map['description'] as String,
    );
  }

  MaintenanceSchedule copyWith({
    String? id,
    String? vehicleId,
    String? title,
    DateTime? dueDate,
    bool? isCompleted,
    String? description,
  }) {
    return MaintenanceSchedule(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      description: description ?? this.description,
    );
  }
}
