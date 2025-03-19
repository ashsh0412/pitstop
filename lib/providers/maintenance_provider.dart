import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/maintenance_schedule.dart';

class MaintenanceProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<MaintenanceSchedule> _schedules = [];

  List<MaintenanceSchedule> get schedules => List.unmodifiable(_schedules);
  List<MaintenanceSchedule> get activeSchedules =>
      _schedules.where((s) => !s.isCompleted).toList();
  List<MaintenanceSchedule> get completedSchedules =>
      _schedules.where((s) => s.isCompleted).toList();

  // 특정 차량의 유지보수 일정 로드
  Future<void> loadSchedules(int vehicleId) async {
    final scheduleData = await _db.getMaintenanceSchedules(vehicleId);
    _schedules =
        scheduleData.map((map) => MaintenanceSchedule.fromMap(map)).toList();
    notifyListeners();
  }

  // 유지보수 일정 추가
  Future<void> addSchedule(MaintenanceSchedule schedule) async {
    final id = await _db.insertMaintenanceSchedule(schedule.toMap());
    final newSchedule = MaintenanceSchedule(
      id: id,
      vehicleId: schedule.vehicleId,
      title: schedule.title,
      description: schedule.description,
      dueDate: schedule.dueDate,
      dueMileage: schedule.dueMileage,
      isCompleted: schedule.isCompleted,
      completedAt: schedule.completedAt,
      createdAt: schedule.createdAt,
    );

    _schedules.insert(0, newSchedule);
    _sortSchedules();
    notifyListeners();
  }

  // 유지보수 일정 업데이트
  Future<void> updateSchedule(MaintenanceSchedule schedule) async {
    if (schedule.id == null) return;

    await _db.updateMaintenanceSchedule(schedule.toMap());
    final index = _schedules.indexWhere((s) => s.id == schedule.id);

    if (index != -1) {
      _schedules[index] = schedule;
      _sortSchedules();
      notifyListeners();
    }
  }

  // 유지보수 일정 완료 처리
  Future<void> completeSchedule(MaintenanceSchedule schedule) async {
    if (schedule.id == null) return;

    final completedSchedule = schedule.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    await _db.completeMaintenanceTask(schedule.id!);
    final index = _schedules.indexWhere((s) => s.id == schedule.id);

    if (index != -1) {
      _schedules[index] = completedSchedule;
      _sortSchedules();
      notifyListeners();
    }
  }

  // 유지보수 일정 삭제
  Future<void> deleteSchedule(MaintenanceSchedule schedule) async {
    if (schedule.id == null) return;

    await _db.deleteMaintenanceSchedule(schedule.id!);
    _schedules.removeWhere((s) => s.id == schedule.id);
    notifyListeners();
  }

  // 일정 정렬 (미완료 > 완료, 날짜순)
  void _sortSchedules() {
    _schedules.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }

      final aDate = a.dueDate ?? DateTime(9999);
      final bDate = b.dueDate ?? DateTime(9999);
      return aDate.compareTo(bDate);
    });
  }
}
