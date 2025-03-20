import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';
import '../models/diagnostic_code.dart';

class OBDService {
  final Logger _logger = Logger();
  BluetoothDevice? _device;
  BluetoothCharacteristic? _characteristic;
  StreamSubscription? _subscription;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> connect(BluetoothDevice device) async {
    try {
      _device = device;
      await device.connect();
      _logger.i('Connected to device: ${device.name}');

      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            _characteristic = characteristic;
            _isConnected = true;
            _logger.i('Found write characteristic');
            break;
          }
        }
        if (_characteristic != null) break;
      }

      if (_characteristic == null) {
        throw Exception('No write characteristic found');
      }

      // Subscribe to notifications
      await _characteristic!.setNotifyValue(true);
      _subscription = _characteristic!.value.listen((value) {
        _handleResponse(value);
      });
    } catch (e) {
      _logger.e('Error connecting to device: $e');
      _isConnected = false;
      rethrow;
    }
  }

  Future<void> disconnect() async {
    try {
      await _subscription?.cancel();
      await _device?.disconnect();
      _isConnected = false;
      _logger.i('Disconnected from device');
    } catch (e) {
      _logger.e('Error disconnecting from device: $e');
      rethrow;
    }
  }

  Future<void> sendCommand(String command) async {
    if (!_isConnected || _characteristic == null) {
      throw Exception('Not connected to device');
    }

    try {
      // Add carriage return to command
      final cmd = '$command\r';
      await _characteristic!.write(utf8.encode(cmd));
      _logger.d('Sent command: $command');
    } catch (e) {
      _logger.e('Error sending command: $e');
      rethrow;
    }
  }

  void _handleResponse(List<int> value) {
    if (value.isEmpty) return;

    final response = utf8.decode(value);
    _logger.d('Received response: $response');

    // Handle different types of responses
    if (response.startsWith('43')) {
      // DTC response
      _parseDTCResponse(response);
    } else if (response.startsWith('41')) {
      // Mode 01 response
      _parseMode01Response(response);
    }
  }

  void _parseDTCResponse(String response) {
    // Remove the mode and PID bytes
    final dtcData = response.substring(4);
    final dtcs = <String>[];

    // Parse DTCs (2 bytes each)
    for (var i = 0; i < dtcData.length; i += 4) {
      if (i + 4 <= dtcData.length) {
        final dtc = dtcData.substring(i, i + 4);
        dtcs.add(dtc);
      }
    }

    _logger.i('Parsed DTCs: $dtcs');
    // TODO: Notify listeners of DTCs
  }

  void _parseMode01Response(String response) {
    // Remove the mode and PID bytes
    final data = response.substring(4);
    _logger.i('Parsed Mode 01 data: $data');
    // TODO: Parse specific PIDs and notify listeners
  }

  Future<List<DiagnosticCode>> getDiagnosticCodes() async {
    if (!_isConnected) {
      throw Exception('Not connected to device');
    }

    try {
      // Request DTCs
      await sendCommand('03');
      // Wait for response
      await Future.delayed(const Duration(milliseconds: 500));

      // For now, return some sample DTCs
      return [
        DiagnosticCode.getByCode('P0301'),
        DiagnosticCode.getByCode('P0171'),
        DiagnosticCode.getByCode('P0420'),
      ];
    } catch (e) {
      _logger.e('Error getting diagnostic codes: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getLiveData() async {
    if (!_isConnected) {
      throw Exception('Not connected to device');
    }

    try {
      // Request various PIDs
      await sendCommand('010C'); // RPM
      await sendCommand('010D'); // Speed
      await sendCommand('010F'); // Intake Air Temperature
      await sendCommand('0110'); // Mass Air Flow Sensor (MAF) Air Flow Rate
      await sendCommand('0111'); // Throttle Position
      await sendCommand('0112'); // Commanded Secondary Air Status
      await sendCommand('0113'); // Oxygen Sensor 1
      await sendCommand('0114'); // Oxygen Sensor 2
      await sendCommand('0115'); // Oxygen Sensor 3
      await sendCommand('0116'); // Oxygen Sensor 4
      await sendCommand('0117'); // Oxygen Sensor 5
      await sendCommand('0118'); // Oxygen Sensor 6
      await sendCommand('0119'); // Oxygen Sensor 7
      await sendCommand('011A'); // Oxygen Sensor 8
      await sendCommand('011B'); // OBD standards this vehicle conforms to
      await sendCommand('011C'); // OBD standards this vehicle conforms to
      await sendCommand('011D'); // OBD standards this vehicle conforms to
      await sendCommand('011E'); // OBD standards this vehicle conforms to
      await sendCommand('011F'); // OBD standards this vehicle conforms to
      await sendCommand('0120'); // PIDs supported 21-40
      await sendCommand(
          '0121'); // Distance traveled with malfunction indicator lamp (MIL) on
      await sendCommand('0122'); // Fuel Rail Pressure (relative to vacuum)
      await sendCommand(
          '0123'); // Fuel Rail Gauge Pressure (diesel, or gasoline direct injection)
      await sendCommand('0124'); // Oxygen Sensor 1
      await sendCommand('0125'); // Oxygen Sensor 2
      await sendCommand('0126'); // Oxygen Sensor 3
      await sendCommand('0127'); // Oxygen Sensor 4
      await sendCommand('0128'); // Oxygen Sensor 5
      await sendCommand('0129'); // Oxygen Sensor 6
      await sendCommand('012A'); // Oxygen Sensor 7
      await sendCommand('012B'); // Oxygen Sensor 8
      await sendCommand('012C'); // Commanded EGR
      await sendCommand('012D'); // EGR Error
      await sendCommand('012E'); // Commanded Evaporative Purge
      await sendCommand('012F'); // Fuel Level Input
      await sendCommand('0130'); // Number of warm-ups since codes cleared
      await sendCommand('0131'); // Distance traveled since codes cleared
      await sendCommand('0132'); // Evap. System Vapor Pressure
      await sendCommand('0133'); // Absolute Barometric Pressure
      await sendCommand('0134'); // Oxygen Sensor 1
      await sendCommand('0135'); // Oxygen Sensor 2
      await sendCommand('0136'); // Oxygen Sensor 3
      await sendCommand('0137'); // Oxygen Sensor 4
      await sendCommand('0138'); // Oxygen Sensor 5
      await sendCommand('0139'); // Oxygen Sensor 6
      await sendCommand('013A'); // Oxygen Sensor 7
      await sendCommand('013B'); // Oxygen Sensor 8
      await sendCommand('013C'); // Catalyst Temperature Bank 1 Sensor 1
      await sendCommand('013D'); // Catalyst Temperature Bank 2 Sensor 1
      await sendCommand('013E'); // Catalyst Temperature Bank 1 Sensor 2
      await sendCommand('013F'); // Catalyst Temperature Bank 2 Sensor 2

      // Wait for responses
      await Future.delayed(const Duration(milliseconds: 500));

      // For now, return sample data
      return {
        'rpm': 2000,
        'speed': 60,
        'intakeAirTemp': 25,
        'maf': 2.5,
        'throttlePosition': 15,
        'fuelLevel': 75,
        'barometricPressure': 101,
        'catalystTemp1': 600,
        'catalystTemp2': 550,
      };
    } catch (e) {
      _logger.e('Error getting live data: $e');
      rethrow;
    }
  }
}
