import 'package:flutter/foundation.dart';
import '../models/maintenance_schedule.dart';

class MaintenanceProvider with ChangeNotifier {
  final List<MaintenanceSchedule> _schedules = [
    MaintenanceSchedule(
      id: '1',
      vehicleId: '1',
      title: '엔진 오일 교체',
      description: '정기 엔진 오일 교체',
      dueDate: DateTime.now().add(const Duration(days: 30)),
      isCompleted: false,
    ),
    MaintenanceSchedule(
      id: '2',
      vehicleId: '1',
      title: '타이어 교체',
      description: '겨울용 타이어로 교체',
      dueDate: DateTime.now().add(const Duration(days: 60)),
      isCompleted: false,
    ),
    MaintenanceSchedule(
      id: '3',
      vehicleId: '1',
      title: '브레이크 패드 점검',
      description: '브레이크 패드 마모도 확인',
      dueDate: DateTime.now().add(const Duration(days: 90)),
      isCompleted: true,
    ),
  ];

  List<MaintenanceSchedule> get schedules => List.unmodifiable(_schedules);
  List<MaintenanceSchedule> get activeSchedules =>
      _schedules.where((s) => !s.isCompleted).toList();
  List<MaintenanceSchedule> get completedSchedules =>
      _schedules.where((s) => s.isCompleted).toList();

  void addSchedule(MaintenanceSchedule schedule) {
    _schedules.insert(0, schedule);
    _sortSchedules();
    notifyListeners();
  }

  void updateSchedule(MaintenanceSchedule schedule) {
    final index = _schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _schedules[index] = schedule;
      _sortSchedules();
      notifyListeners();
    }
  }

  void completeSchedule(MaintenanceSchedule schedule) {
    final completedSchedule = schedule.copyWith(
      isCompleted: true,
    );
    final index = _schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _schedules[index] = completedSchedule;
      _sortSchedules();
      notifyListeners();
    }
  }

  void deleteSchedule(MaintenanceSchedule schedule) {
    _schedules.removeWhere((s) => s.id == schedule.id);
    notifyListeners();
  }

  void _sortSchedules() {
    _schedules.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.dueDate.compareTo(b.dueDate);
    });
  }
}
