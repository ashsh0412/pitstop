import 'dart:async';
import 'dart:io' show Platform;
import 'obd_service.dart';
import 'package:flutter/foundation.dart';
import 'diagnostic_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue_plus;
import 'package:permission_handler/permission_handler.dart';

class OBDProvider with ChangeNotifier {
  final OBDService _obdService = OBDService();
  bool _isConnected = false;
  bool _isConnecting = false;
  String _deviceName = '';
  double _speed = 0;
  double _rpm = 0;
  double _engineTemp = 0;
  double _batteryVoltage = 0;
  double _fuelPressure = 0;
  double _intakePressure = 0;
  double _throttlePosition = 0;
  double _engineLoad = 0;
  double _fuelEconomy = 0;
  List<String> _dtc = [];
  final List<DiagnosticCode> _diagnosticCodes = [];
  final Map<String, dynamic> _latestData = {};
  final List<Map<String, dynamic>> _historicalData = [];
  StreamSubscription? dataSubscription;
  DateTime? _lastUpdateTime;
  final bool _isSimulatorMode = false;
  List<blue_plus.BluetoothDevice> _pairedDevices = [];
  List<blue_plus.BluetoothDevice> _discoveredDevices = [];
  bool _isScanning = false;
  bool _isPairing = false;

  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String get deviceName => _deviceName;
  double get speed => _speed;
  double get rpm => _rpm;
  double get engineTemp => _engineTemp;
  double get batteryVoltage => _batteryVoltage;
  double get fuelPressure => _fuelPressure;
  double get intakePressure => _intakePressure;
  double get throttlePosition => _throttlePosition;
  double get engineLoad => _engineLoad;
  double get fuelEconomy => _fuelEconomy;
  List<String> get dtc => _dtc;
  Map<String, dynamic> get latestData => _latestData;
  List<Map<String, dynamic>> get historicalData => _historicalData;
  List<DiagnosticCode> get diagnosticCodes => _diagnosticCodes;
  DateTime? get lastUpdateTime => _lastUpdateTime;
  bool get isSimulatorMode => _isSimulatorMode;
  List<blue_plus.BluetoothDevice> get pairedDevices => _pairedDevices;
  List<blue_plus.BluetoothDevice> get discoveredDevices => _discoveredDevices;
  bool get isScanning => _isScanning;
  bool get isPairing => _isPairing;

  OBDProvider() {
    _initBluetooth();
    _listenToOBDData();
  }

  Future<void> _initBluetooth() async {
    try {
      // Request Bluetooth permissions first
      final bluetoothStatus = await Permission.bluetooth.request();
      final bluetoothScanStatus = await Permission.bluetoothScan.request();
      final bluetoothConnectStatus =
          await Permission.bluetoothConnect.request();

      // Only request location if Bluetooth permissions are granted
      if (bluetoothStatus.isGranted &&
          bluetoothScanStatus.isGranted &&
          bluetoothConnectStatus.isGranted) {
        // Check if location permission is needed (Android only)
        if (Platform.isAndroid) {
          final locationStatus = await Permission.location.request();
          if (!locationStatus.isGranted) {
            debugPrint(
                'Location permission is required for Bluetooth scanning on Android');
            return;
          }
        }

        // Initialize FlutterBluePlus
        if (await blue_plus.FlutterBluePlus.isAvailable) {
          debugPrint('Bluetooth is available');

          // Check if Bluetooth is on
          if (await blue_plus.FlutterBluePlus.isOn) {
            debugPrint('Bluetooth is on');
            _updatePairedDevices();
          } else {
            debugPrint('Bluetooth is off');
            // Try to turn on Bluetooth
            await blue_plus.FlutterBluePlus.turnOn();
            _updatePairedDevices();
          }
        } else {
          debugPrint('Bluetooth is not available');
        }
      } else {
        debugPrint('Required Bluetooth permissions not granted');
      }
    } catch (e) {
      debugPrint('Error initializing Bluetooth: $e');
    }
  }

  Future<void> _updatePairedDevices() async {
    try {
      final bondedDevices = await blue_plus.FlutterBluePlus.bondedDevices;
      _pairedDevices = bondedDevices.toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting paired devices: $e');
    }
  }

  void _listenToOBDData() {
    _obdService.dataStream.listen((data) {
      _speed = (data['speed'] ?? 0).toDouble();
      _rpm = (data['rpm'] ?? 0).toDouble();
      _engineTemp = (data['engineTemp'] ?? 0).toDouble();
      _batteryVoltage = (data['batteryVoltage'] ?? 0).toDouble();
      _fuelPressure = (data['fuelPressure'] ?? 0).toDouble();
      _intakePressure = (data['intakePressure'] ?? 0).toDouble();
      _throttlePosition = (data['throttlePosition'] ?? 0).toDouble();
      _engineLoad = (data['engineLoad'] ?? 0).toDouble();
      _fuelEconomy = (data['fuelEconomy'] ?? 0).toDouble();
      _dtc = List<String>.from(data['dtc'] ?? []);
      notifyListeners();
    });
  }

  String getDeviceDisplayName(blue_plus.BluetoothDevice device) {
    if (device.platformName.isNotEmpty ?? false) {
      return device.platformName;
    }

    // If no name, use the MAC address/ID with a prefix
    return 'Device (${device.remoteId.toString()})';
  }

  Future<void> startScan() async {
    if (_isScanning) return;

    try {
      // Check permissions before scanning
      if (Platform.isAndroid) {
        final locationStatus = await Permission.location.status;
        if (!locationStatus.isGranted) {
          debugPrint('Location permission is required for scanning');
          return;
        }
      }

      if (!await blue_plus.FlutterBluePlus.isOn) {
        debugPrint('Turning on Bluetooth...');
        await blue_plus.FlutterBluePlus.turnOn();
      }

      _isScanning = true;
      _discoveredDevices = [];
      notifyListeners();

      debugPrint('Starting scan...');

      final subscription =
          blue_plus.FlutterBluePlus.scanResults.listen((results) {
        debugPrint('Found ${results.length} devices');
        for (blue_plus.ScanResult result in results) {
          final deviceName = getDeviceDisplayName(result.device);
          debugPrint(
            'Device: $deviceName\n'
            'ID: ${result.device.remoteId}\n'
            'RSSI: ${result.rssi} dBm\n'
            'Status: ${result.device.isConnected ? "Connected" : "Not Connected"}\n'
            '-------------------',
          );

          // Only add devices that are not already in the list
          if (!_discoveredDevices.contains(result.device) &&
              !_pairedDevices.contains(result.device)) {
            _discoveredDevices.add(result.device);
            notifyListeners();
          }
        }
      });

      await blue_plus.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4),
        androidUsesFineLocation: true,
      );

      await Future.delayed(const Duration(seconds: 4));
      await subscription.cancel();

      // Sort devices: named devices first, then unnamed devices
      _discoveredDevices.sort((a, b) {
        final aHasName = a.platformName.isNotEmpty ?? false;
        final bHasName = b.platformName.isNotEmpty ?? false;

        if (aHasName && !bHasName) return -1;
        if (!aHasName && bHasName) return 1;

        return getDeviceDisplayName(a).compareTo(getDeviceDisplayName(b));
      });

      _isScanning = false;
      notifyListeners();
    } catch (e) {
      _isScanning = false;
      notifyListeners();
      debugPrint('Error scanning: $e');
    }
  }

  Future<void> stopScan() async {
    if (!_isScanning) return;

    try {
      await blue_plus.FlutterBluePlus.stopScan();
      _isScanning = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping scan: $e');
    }
  }

  Future<void> connect(blue_plus.BluetoothDevice device,
      {bool useSimulator = false}) async {
    try {
      _isConnecting = true;
      notifyListeners();

      await _obdService.connect(device, useSimulator: useSimulator);
      _isConnected = true;
      _deviceName = device.platformName ?? 'Unknown Device';
      _isPairing = false;
      notifyListeners();
    } catch (e) {
      _isConnected = false;
      _deviceName = '';
      _isPairing = false;
      notifyListeners();
      debugPrint('Error connecting to device: $e');
      rethrow;
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    try {
      await _obdService.disconnect();
      _isConnected = false;
      _deviceName = '';
      notifyListeners();
    } catch (e) {
      debugPrint('Error disconnecting: $e');
    }
  }

  Future<void> unpairDevice(blue_plus.BluetoothDevice device) async {
    try {
      // Unpair device
      await device.disconnect();
      _updatePairedDevices();
    } catch (e) {
      debugPrint('Error unpairing device: $e');
    }
  }

  @override
  void dispose() {
    _obdService.dispose();
    super.dispose();
  }
}
