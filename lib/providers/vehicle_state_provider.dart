import 'package:flutter/foundation.dart';

enum VehicleState {
  parked, // 정차 상태 (엔진 OFF 또는 IDLE)
  driving, // 주행 상태 (엔진 ON & 속도 > 0)
}

class VehicleStateProvider with ChangeNotifier {
  VehicleState _currentState = VehicleState.parked;
  bool _isEngineOn = false;
  double _currentSpeed = 0.0;

  VehicleState get currentState => _currentState;
  bool get isEngineOn => _isEngineOn;
  double get currentSpeed => _currentSpeed;

  // 차량 상태 업데이트
  void updateVehicleState({required bool engineOn, required double speed}) {
    _isEngineOn = engineOn;
    _currentSpeed = speed;

    // 차량 상태 결정
    if (!engineOn || speed == 0) {
      _currentState = VehicleState.parked;
    } else {
      _currentState = VehicleState.driving;
    }

    notifyListeners();
  }

  // 특정 기능의 사용 가능 여부 확인
  bool canUseDiagnostics() {
    return _currentState == VehicleState.parked;
  }

  bool canUseMaintenanceFeatures() {
    return _currentState == VehicleState.parked;
  }

  bool shouldShowRealTimeData() {
    return _isEngineOn; // 엔진이 켜져있을 때만 실시간 데이터 표시
  }
}
