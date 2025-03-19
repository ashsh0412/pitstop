import 'package:flutter/foundation.dart';

enum DTCSeverity { critical, warning, info }

class DiagnosticCode {
  final String code;
  final String description;
  final DTCSeverity severity;
  final String possibleCauses;
  final String solutions;
  final DateTime timestamp;

  DiagnosticCode({
    required this.code,
    required this.description,
    required this.severity,
    required this.possibleCauses,
    required this.solutions,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class DiagnosticsProvider with ChangeNotifier {
  final List<DiagnosticCode> _dtcs = [];
  bool _isConnected = false;

  List<DiagnosticCode> get dtcs => List.unmodifiable(_dtcs);
  bool get isConnected => _isConnected;

  int get criticalCount =>
      _dtcs.where((dtc) => dtc.severity == DTCSeverity.critical).length;
  int get warningCount =>
      _dtcs.where((dtc) => dtc.severity == DTCSeverity.warning).length;
  int get infoCount =>
      _dtcs.where((dtc) => dtc.severity == DTCSeverity.info).length;

  void toggleConnection() {
    _isConnected = !_isConnected;
    notifyListeners();
  }

  void refreshDTCs() {
    // 실제로는 OBD2 어댑터에서 DTC를 읽어와야 함
    // 현재는 테스트를 위한 모의 데이터 생성
    _dtcs.clear();
    _generateMockData();
    notifyListeners();
  }

  bool clearDTCs() {
    if (!_isConnected) return false;

    // 실제로는 OBD2 어댑터로 DTC 초기화 명령을 보내야 함
    _dtcs.clear();
    notifyListeners();
    return true;
  }

  void _generateMockData() {
    _dtcs.addAll([
      DiagnosticCode(
        code: 'P0420',
        description: 'Catalyst System Efficiency Below Threshold',
        severity: DTCSeverity.critical,
        possibleCauses: '촉매 변환기 성능 저하, 산소 센서 오작동, 배기 가스 누출',
        solutions: '촉매 변환기 검사 및 교체, 산소 센서 점검, 배기 시스템 누출 검사',
      ),
      DiagnosticCode(
        code: 'P0300',
        description: 'Random/Multiple Cylinder Misfire Detected',
        severity: DTCSeverity.warning,
        possibleCauses: '점화 플러그 마모, 연료 분사 문제, 압축 압력 부족',
        solutions: '점화 플러그 교체, 연료 시스템 점검, 엔진 압축 테스트',
      ),
      DiagnosticCode(
        code: 'P0171',
        description: 'System Too Lean (Bank 1)',
        severity: DTCSeverity.warning,
        possibleCauses: '진공 누출, MAF 센서 오작동, 연료 압력 부족',
        solutions: '진공 라인 점검, MAF 센서 청소 또는 교체, 연료 시스템 점검',
      ),
      DiagnosticCode(
        code: 'P0456',
        description:
            'Evaporative Emission System Leak Detected (Very Small Leak)',
        severity: DTCSeverity.info,
        possibleCauses: '연료 캡 느슨함, EVAP 호스 손상, 퍼지 밸브 오작동',
        solutions: '연료 캡 체결 상태 확인, EVAP 시스템 누출 검사, 퍼지 밸브 점검',
      ),
    ]);
  }

  // 실제 구현 시 추가될 메서드들:
  // Future<void> readDTCs() async { ... }
  // Future<void> freezeFrameData(String dtcCode) async { ... }
}
