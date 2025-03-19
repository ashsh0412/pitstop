import 'package:flutter/foundation.dart';

enum AlertSeverity { critical, warning, info }

class VehicleAlert {
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final bool requiresImmediateAction;

  VehicleAlert({
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.requiresImmediateAction = false,
  });
}

class VehicleAlertProvider with ChangeNotifier {
  final List<VehicleAlert> _alerts = [];
  bool _isVoiceAlertEnabled = true;

  List<VehicleAlert> get alerts => List.unmodifiable(_alerts);
  bool get isVoiceAlertEnabled => _isVoiceAlertEnabled;

  void toggleVoiceAlert() {
    _isVoiceAlertEnabled = !_isVoiceAlertEnabled;
    notifyListeners();
  }

  void addAlert({
    required String title,
    required String message,
    required AlertSeverity severity,
    bool requiresImmediateAction = false,
  }) {
    final alert = VehicleAlert(
      title: title,
      message: message,
      severity: severity,
      timestamp: DateTime.now(),
      requiresImmediateAction: requiresImmediateAction,
    );

    _alerts.insert(0, alert); // 최신 알림을 맨 앞에 추가
    if (_alerts.length > 50) {
      _alerts.removeLast(); // 최대 50개까지만 유지
    }

    notifyListeners();
  }

  void clearAlerts() {
    _alerts.clear();
    notifyListeners();
  }

  // 차량 데이터 기반 경고 생성
  void checkVehicleData({
    required double engineTemp,
    required double batteryVoltage,
    required double fuelLevel,
  }) {
    // 엔진 과열 체크
    if (engineTemp > 105) {
      // 105°C 이상
      addAlert(
        title: '엔진 과열',
        message: '엔진 온도가 위험 수준입니다. 즉시 정차하세요.',
        severity: AlertSeverity.critical,
        requiresImmediateAction: true,
      );
    } else if (engineTemp > 95) {
      // 95°C 이상
      addAlert(
        title: '엔진 온도 상승',
        message: '엔진이 평소보다 뜨겁습니다. 상태를 주의 깊게 관찰하세요.',
        severity: AlertSeverity.warning,
      );
    }

    // 배터리 전압 체크
    if (batteryVoltage < 11.5) {
      addAlert(
        title: '배터리 전압 저하',
        message: '배터리 전압이 낮습니다. 충전 시스템을 점검하세요.',
        severity: AlertSeverity.warning,
      );
    }

    // 연료량 체크
    if (fuelLevel < 0.1) {
      // 10% 미만
      addAlert(
        title: '연료 부족',
        message: '연료가 얼마 남지 않았습니다. 가까운 주유소를 찾으세요.',
        severity: AlertSeverity.warning,
      );
    }
  }
}
