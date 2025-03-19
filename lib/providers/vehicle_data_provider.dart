import 'package:flutter/foundation.dart';

class VehicleData {
  final double rpm;
  final double speed;
  final double voltage;
  final double fuelEfficiency;
  final double engineTemp;
  final double throttlePosition;

  VehicleData({
    this.rpm = 0.0,
    this.speed = 0.0,
    this.voltage = 12.0,
    this.fuelEfficiency = 0.0,
    this.engineTemp = 0.0,
    this.throttlePosition = 0.0,
  });
}

class VehicleDataProvider with ChangeNotifier {
  VehicleData _data = VehicleData();

  VehicleData get data => _data;

  // Simulate real-time data updates (will be replaced with actual OBD2 data later)
  void updateMockData() {
    _data = VehicleData(
      rpm: 800 + (DateTime.now().millisecond % 1000).toDouble(),
      speed: 60 + (DateTime.now().second % 20).toDouble(),
      voltage: 12.0 + (DateTime.now().millisecond % 1000) / 1000,
      fuelEfficiency: 25 + (DateTime.now().second % 10).toDouble(),
      engineTemp: 90 + (DateTime.now().second % 10).toDouble(),
      throttlePosition: (DateTime.now().millisecond % 100).toDouble(),
    );
    notifyListeners();
  }
}
