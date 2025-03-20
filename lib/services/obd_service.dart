import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue_plus;
import 'package:logger/logger.dart';

class OBDService {
  static const String OBD_SERVICE_UUID = "00001101-0000-1000-8000-00805F9B34FB";
  static const String OBD_CHAR_UUID = "00001101-0000-1000-8000-00805F9B34FB";

  // PIDs for OBD-II
  static const String SPEED_PID = "0D";
  static const String RPM_PID = "0C";
  static const String ENGINE_TEMP_PID = "05";
  static const String BATTERY_VOLTAGE_PID = "42";
  static const String FUEL_PRESSURE_PID = "0A";
  static const String INTAKE_PRESSURE_PID = "0B";
  static const String THROTTLE_POSITION_PID = "11";
  static const String ENGINE_LOAD_PID = "04";
  static const String FUEL_ECONOMY_PID = "5E";

  final Logger _logger = Logger();
  blue_plus.BluetoothDevice? _device;
  blue_plus.BluetoothCharacteristic? _characteristic;
  Timer? _dataTimer;
  bool _isConnected = false;
  bool _isSimulatorMode = false;
  final _random = math.Random();

  // Stream controllers for data updates
  final _dataController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get dataStream => _dataController.stream;

  bool get isConnected => _isConnected;
  bool get isSimulatorMode => _isSimulatorMode;

  // Connect to OBD device
  Future<void> connect(blue_plus.BluetoothDevice device,
      {bool useSimulator = false}) async {
    try {
      _isSimulatorMode = useSimulator;
      if (useSimulator) {
        _logger.i('Starting simulator mode');
        _isConnected = true;
        _startDataCollection();
        return;
      }

      _device = device;
      _logger.i(
          'Connecting to device: ${device.platformName ?? "Unknown Device"}');

      // Connect to the device
      await device.connect(timeout: const Duration(seconds: 10));
      _logger.i('Connected to device');

      // Discover services
      _logger.i('Discovering services...');
      List<blue_plus.BluetoothService> services =
          await device.discoverServices();

      // Find OBD service and characteristic
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

      // Enable notifications
      await _characteristic!.setNotifyValue(true);
      _isConnected = true;

      // Initialize OBD communication
      await _initializeOBD();

      // Start data collection
      _startDataCollection();
    } catch (e) {
      _logger.e('Error connecting to device: $e');
      await disconnect();
      rethrow;
    }
  }

  // Initialize OBD communication
  Future<void> _initializeOBD() async {
    try {
      _logger.i('Initializing OBD communication');

      // Reset all
      await _sendCommand("ATZ");
      await Future.delayed(const Duration(milliseconds: 1000));

      // Turn off echo
      await _sendCommand("ATE0");

      // Turn off line feed
      await _sendCommand("ATL0");

      // Set protocol to automatic
      await _sendCommand("ATSP0");

      // Get supported PIDs
      await _sendCommand("0100");

      _logger.i('OBD initialization completed');
    } catch (e) {
      _logger.e('Error initializing OBD: $e');
      rethrow;
    }
  }

  // Disconnect from device
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

  // Send command to OBD device
  Future<List<String>> _sendCommand(String command) async {
    if (_isSimulatorMode) {
      return ['41 ${command.substring(2)} 00'];
    }

    if (_characteristic == null) {
      throw Exception('No characteristic available');
    }

    try {
      // Send command
      await _characteristic!.write(utf8.encode('$command\r'));

      // Wait for response
      final response = await _characteristic!.value
          .timeout(
            const Duration(seconds: 2),
            onTimeout: (sink) =>
                sink.addError(TimeoutException('Command timed out')),
          )
          .first;

      // Parse response
      String responseStr = String.fromCharCodes(response).trim();
      List<String> lines = responseStr.split('\r');
      return lines.where((line) => line.isNotEmpty).toList();
    } catch (e) {
      _logger.e('Error sending command $command: $e');
      rethrow;
    }
  }

  // Start periodic data collection
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
          data['rpm'] = _generateSimulatedValue(800, 6000);
          data['engineTemp'] = _generateSimulatedValue(80, 105);
          data['batteryVoltage'] = _generateSimulatedValue(120, 148) / 10;
          data['fuelPressure'] = _generateSimulatedValue(30, 50);
          data['intakePressure'] = _generateSimulatedValue(90, 105);
          data['throttlePosition'] = _generateSimulatedValue(0, 100);
          data['engineLoad'] = _generateSimulatedValue(0, 100);
          data['fuelEconomy'] = _generateSimulatedValue(80, 160) / 10;
          data['dtc'] = [];
        } else {
          try {
            data['speed'] = await _readPID(SPEED_PID);
            data['rpm'] = await _readPID(RPM_PID);
            data['engineTemp'] = await _readPID(ENGINE_TEMP_PID);
            data['batteryVoltage'] = await _readPID(BATTERY_VOLTAGE_PID);
            data['fuelPressure'] = await _readPID(FUEL_PRESSURE_PID);
            data['intakePressure'] = await _readPID(INTAKE_PRESSURE_PID);
            data['throttlePosition'] = await _readPID(THROTTLE_POSITION_PID);
            data['engineLoad'] = await _readPID(ENGINE_LOAD_PID);
            data['fuelEconomy'] = await _readPID(FUEL_ECONOMY_PID);
            data['dtc'] = await _readDTCs();
          } catch (e) {
            _logger.e('Error reading OBD data: $e');
            // Continue with partial data
          }
        }

        _dataController.add(data);
      } catch (e) {
        _logger.e('Error in data collection: $e');
      }
    });
  }

  // Read PID value
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

      // Convert hex to decimal
      int value = int.parse(parts[2], radix: 16);
      if (parts.length > 3) {
        value = (value << 8) + int.parse(parts[3], radix: 16);
      }

      // Convert based on PID
      switch (pid) {
        case SPEED_PID:
          return value;
        case RPM_PID:
          return value / 4;
        case ENGINE_TEMP_PID:
          return value - 40;
        case BATTERY_VOLTAGE_PID:
          return value / 10;
        case FUEL_PRESSURE_PID:
          return value * 3;
        case INTAKE_PRESSURE_PID:
          return value;
        case THROTTLE_POSITION_PID:
          return (value * 100) / 255;
        case ENGINE_LOAD_PID:
          return (value * 100) / 255;
        case FUEL_ECONOMY_PID:
          return value / 10;
        default:
          return value;
      }
    } catch (e) {
      _logger.e('Error reading PID $pid: $e');
      rethrow;
    }
  }

  // Read DTCs
  Future<List<String>> _readDTCs() async {
    try {
      final response = await _sendCommand('03');
      List<String> dtcs = [];

      for (String line in response) {
        if (line.startsWith('43')) {
          final parts = line.split(' ');
          for (int i = 1; i < parts.length; i += 2) {
            if (parts.length > i + 1) {
              String dtcCode = _decodeDTC(parts[i], parts[i + 1]);
              if (dtcCode.isNotEmpty) {
                dtcs.add(dtcCode);
              }
            }
          }
        }
      }

      return dtcs;
    } catch (e) {
      _logger.e('Error reading DTCs: $e');
      return [];
    }
  }

  // Decode DTC
  String _decodeDTC(String byte1, String byte2) {
    try {
      int firstDigit = int.parse(byte1[0], radix: 16);
      String prefix = '';

      switch (firstDigit) {
        case 0:
          prefix = 'P0';
          break;
        case 1:
          prefix = 'P1';
          break;
        case 2:
          prefix = 'P2';
          break;
        case 3:
          prefix = 'P3';
          break;
        case 4:
          prefix = 'C0';
          break;
        case 5:
          prefix = 'C1';
          break;
        case 6:
          prefix = 'C2';
          break;
        case 7:
          prefix = 'C3';
          break;
        case 8:
          prefix = 'B0';
          break;
        case 9:
          prefix = 'B1';
          break;
        case 10:
          prefix = 'B2';
          break;
        case 11:
          prefix = 'B3';
          break;
        case 12:
          prefix = 'U0';
          break;
        case 13:
          prefix = 'U1';
          break;
        case 14:
          prefix = 'U2';
          break;
        case 15:
          prefix = 'U3';
          break;
        default:
          return '';
      }

      String dtcNumber = byte1[1] + byte2;
      return prefix + dtcNumber;
    } catch (e) {
      _logger.e('Error decoding DTC: $e');
      return '';
    }
  }

  // Generate simulated value
  int _generateSimulatedValue(int min, int max) {
    return min + DateTime.now().millisecondsSinceEpoch % (max - min);
  }

  // Dispose
  void dispose() {
    _dataTimer?.cancel();
    _dataController.close();
    disconnect();
  }
}
