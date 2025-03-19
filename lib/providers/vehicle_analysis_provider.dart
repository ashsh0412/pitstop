import 'package:flutter/foundation.dart';

class VehicleAnalysisData {
  final DateTime timestamp;
  final double speed;
  final double rpm;
  final double fuelEfficiency;

  VehicleAnalysisData({
    required this.timestamp,
    required this.speed,
    required this.rpm,
    required this.fuelEfficiency,
  });
}

class VehicleAnalysisProvider with ChangeNotifier {
  final List<VehicleAnalysisData> _data = [];

  List<VehicleAnalysisData> get data => List.unmodifiable(_data);

  // 최근 24시간 데이터
  List<VehicleAnalysisData> get last24Hours {
    final now = DateTime.now();
    return _data
        .where(
          (d) => d.timestamp.isAfter(now.subtract(const Duration(hours: 24))),
        )
        .toList();
  }

  // 평균 속도
  double get averageSpeed {
    if (_data.isEmpty) return 0;
    return _data.map((d) => d.speed).reduce((a, b) => a + b) / _data.length;
  }

  // 평균 연비
  double get averageFuelEfficiency {
    if (_data.isEmpty) return 0;
    return _data.map((d) => d.fuelEfficiency).reduce((a, b) => a + b) /
        _data.length;
  }

  // 최고 속도
  double get maxSpeed {
    if (_data.isEmpty) return 0;
    return _data.map((d) => d.speed).reduce((a, b) => a > b ? a : b);
  }

  // 모의 데이터 생성 (테스트용)
  void generateMockData() {
    _data.clear();
    final now = DateTime.now();

    for (int i = 0; i < 100; i++) {
      _data.add(
        VehicleAnalysisData(
          timestamp: now.subtract(Duration(minutes: i * 15)),
          speed: 60 + (i % 30) + (i % 5) * 2,
          rpm: 1500 + (i % 500),
          fuelEfficiency: 12 + (i % 8),
        ),
      );
    }
    notifyListeners();
  }
}
