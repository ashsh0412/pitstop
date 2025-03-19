import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/vehicle.dart';

class VehicleProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  Vehicle? get selectedVehicle => _selectedVehicle;

  // 모든 차량 로드
  Future<void> loadVehicles() async {
    final vehicleData = await _db.getVehicles();
    _vehicles = vehicleData.map((map) => Vehicle.fromMap(map)).toList();

    // 저장된 차량이 있고 선택된 차량이 없으면 첫 번째 차량 선택
    if (_vehicles.isNotEmpty && _selectedVehicle == null) {
      _selectedVehicle = _vehicles.first;
    }

    notifyListeners();
  }

  // 차량 추가
  Future<void> addVehicle(Vehicle vehicle) async {
    final id = await _db.insertVehicle(vehicle.toMap());
    final newVehicle = Vehicle(
      id: id,
      name: vehicle.name,
      make: vehicle.make,
      model: vehicle.model,
      year: vehicle.year,
      vin: vehicle.vin,
      createdAt: vehicle.createdAt,
    );

    _vehicles.insert(0, newVehicle);

    // 첫 번째 차량이면 자동 선택
    if (_vehicles.length == 1) {
      _selectedVehicle = newVehicle;
    }

    notifyListeners();
  }

  // 차량 선택
  void selectVehicle(Vehicle vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  // 차량 정보 업데이트
  Future<void> updateVehicle(Vehicle vehicle) async {
    if (vehicle.id == null) return;

    await _db.updateVehicle(vehicle.toMap());
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);

    if (index != -1) {
      _vehicles[index] = vehicle;
      if (_selectedVehicle?.id == vehicle.id) {
        _selectedVehicle = vehicle;
      }
      notifyListeners();
    }
  }

  // 차량 삭제
  Future<void> deleteVehicle(Vehicle vehicle) async {
    if (vehicle.id == null) return;

    await _db.deleteVehicle(vehicle.id!);
    _vehicles.removeWhere((v) => v.id == vehicle.id);

    if (_selectedVehicle?.id == vehicle.id) {
      _selectedVehicle = _vehicles.isNotEmpty ? _vehicles.first : null;
    }

    notifyListeners();
  }
}
