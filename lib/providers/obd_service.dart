import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue_plus;
import 'package:logger/logger.dart';

/// OBD (On-Board Diagnostics) 서비스 클래스
/// OBD-II 블루투스 장치와 통신하여 차량의 상태 및 진단 데이터를 가져옴
class OBDService {
  // OBD 서비스 및 특성 UUID (블루투스 SPP 프로토콜용)
  static const String OBD_SERVICE_UUID = "00001101-0000-1000-8000-00805F9B34FB";
  static const String OBD_CHAR_UUID = "00001101-0000-1000-8000-00805F9B34FB";

  // OBD-II PID (Parameter IDs) - 차량 데이터 조회용
  static const String SPEED_PID = "0D";
  static const String RPM_PID = "0C";
  static const String ENGINE_TEMP_PID = "05";
  static const String BATTERY_VOLTAGE_PID = "42";
  static const String FUEL_PRESSURE_PID = "0A";
  static const String INTAKE_PRESSURE_PID = "0B";
  static const String THROTTLE_POSITION_PID = "11";
  static const String ENGINE_LOAD_PID = "04";
  static const String FUEL_ECONOMY_PID = "5E";

  final Logger _logger = Logger(); // 로깅 도구
  blue_plus.BluetoothDevice? _device; // 현재 연결된 블루투스 장치
  blue_plus.BluetoothCharacteristic? _characteristic; // OBD-II 블루투스 특성
  Timer? _dataTimer; // 데이터 주기적 수집용 타이머
  bool _isConnected = false; // 연결 상태
  bool _isSimulatorMode = false; // 시뮬레이터 모드 (테스트용)
  final _random = math.Random(); // 난수 생성기

  // OBD 데이터 스트림 (UI에서 실시간으로 데이터 받기 위함)
  final _dataController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get dataStream => _dataController.stream;

  bool get isConnected => _isConnected;
  bool get isSimulatorMode => _isSimulatorMode;

  /// OBD 블루투스 장치에 연결
  Future<void> connect(blue_plus.BluetoothDevice device,
      {bool useSimulator = false}) async {
    try {
      _isSimulatorMode = useSimulator;

      if (useSimulator) {
        // 시뮬레이터 모드 활성화
        _logger.i('Starting simulator mode');
        _isConnected = true;
        _startDataCollection();
        return;
      }

      _device = device;
      _logger.i(
          'Connecting to device: ${device.platformName ?? "Unknown Device"}');

      // 블루투스 장치 연결 (10초 제한)
      await device.connect(timeout: const Duration(seconds: 10));
      _logger.i('Connected to device');

      // 서비스 검색
      _logger.i('Discovering services...');
      List<blue_plus.BluetoothService> services =
          await device.discoverServices();

      // OBD 특성 찾기
      for (blue_plus.BluetoothService service in services) {
        for (blue_plus.BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.write &&
              characteristic.properties.notify) {
            _characteristic = characteristic;
            break;
          }
        }
        if (_characteristic != null) break;
      }

      if (_characteristic == null) {
        throw Exception('OBD characteristic not found');
      }

      // 데이터 알림 활성화
      await _characteristic!.setNotifyValue(true);
      _isConnected = true;

      // OBD-II 초기화
      await _initializeOBD();

      // 데이터 수집 시작
      _startDataCollection();
    } catch (e) {
      _logger.e('Error connecting to device: $e');
      await disconnect();
      rethrow;
    }
  }

  /// OBD-II 초기화 명령 실행
  Future<void> _initializeOBD() async {
    try {
      _logger.i('Initializing OBD communication');

      // OBD-II 설정 초기화
      await _sendCommand("ATZ"); // 장치 리셋
      await Future.delayed(const Duration(milliseconds: 1000));
      await _sendCommand("ATE0"); // 에코 끄기
      await _sendCommand("ATL0"); // 줄바꿈 제거
      await _sendCommand("ATSP0"); // 자동 프로토콜 설정
      await _sendCommand("0100"); // 지원되는 PID 요청

      _logger.i('OBD initialization completed');
    } catch (e) {
      _logger.e('Error initializing OBD: $e');
      rethrow;
    }
  }

  /// OBD 장치 연결 해제
  Future<void> disconnect() async {
    try {
      _dataTimer?.cancel();
      _isConnected = false;

      if (!_isSimulatorMode && _device != null) {
        await _device!.disconnect();
        _logger.i('Disconnected from device');
      }

      _device = null;
      _characteristic = null;
    } catch (e) {
      _logger.e('Error disconnecting: $e');
    }
  }

  /// OBD-II 명령어 전송 및 응답 처리
  Future<List<String>> _sendCommand(String command) async {
    if (_isSimulatorMode) {
      return ['41 ${command.substring(2)} 00'];
    }

    if (_characteristic == null) {
      throw Exception('No characteristic available');
    }

    try {
      // 명령어 전송
      await _characteristic!.write(utf8.encode('$command\r'));

      // 응답 수신
      final response = await _characteristic!.value
          .timeout(const Duration(seconds: 2))
          .first;

      // 응답 파싱
      String responseStr = String.fromCharCodes(response).trim();
      List<String> lines = responseStr.split('\r');
      return lines.where((line) => line.isNotEmpty).toList();
    } catch (e) {
      _logger.e('Error sending command $command: $e');
      rethrow;
    }
  }

  /// OBD 데이터 주기적 수집 시작 (1초마다 업데이트)
  void _startDataCollection() {
    _dataTimer?.cancel();
    _dataTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!_isConnected) {
        timer.cancel();
        return;
      }

      try {
        final Map<String, dynamic> data = {};

        if (_isSimulatorMode) {
          data['speed'] = _generateSimulatedValue(0, 180);
        } else {
          try {
            data['speed'] = await _readPID(SPEED_PID);
          } catch (e) {
            _logger.e('Error reading OBD data: $e');
          }
        }

        _dataController.add(data);
      } catch (e) {
        _logger.e('Error in data collection: $e');
      }
    });
  }

  /// PID 데이터를 읽고 변환
  Future<num> _readPID(String pid) async {
    try {
      final response = await _sendCommand('01$pid');
      if (response.isEmpty) {
        throw Exception('Empty response');
      }

      final parts = response[0].split(' ');
      if (parts.length < 3) {
        throw Exception('Invalid response format');
      }

      int value = int.parse(parts[2], radix: 16);
      if (parts.length > 3) {
        value = (value << 8) + int.parse(parts[3], radix: 16);
      }

      return value;
    } catch (e) {
      _logger.e('Error reading PID $pid: $e');
      rethrow;
    }
  }

  /// 시뮬레이터 모드에서 데이터 생성
  int _generateSimulatedValue(int min, int max) {
    return min + DateTime.now().millisecondsSinceEpoch % (max - min);
  }

  /// 객체 해제 및 연결 해제
  void dispose() {
    _dataTimer?.cancel();
    _dataController.close();
    disconnect();
  }
}
