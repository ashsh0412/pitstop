import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isDarkMode = false;
  bool _useMetricSystem = true;
  bool _useCelsius = true;
  int _updateInterval = 1000; // milliseconds

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get useMetricSystem => _useMetricSystem;
  bool get useCelsius => _useCelsius;
  int get updateInterval => _updateInterval;

  // Initialize settings
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  // Load settings from SharedPreferences
  void _loadSettings() {
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    _useMetricSystem = _prefs.getBool('useMetricSystem') ?? true;
    _useCelsius = _prefs.getBool('useCelsius') ?? true;
    _updateInterval = _prefs.getInt('updateInterval') ?? 1000;
    notifyListeners();
  }

  // Update dark mode
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  // Update measurement system
  Future<void> setMetricSystem(bool value) async {
    _useMetricSystem = value;
    await _prefs.setBool('useMetricSystem', value);
    notifyListeners();
  }

  // Update temperature unit
  Future<void> setUseCelsius(bool value) async {
    _useCelsius = value;
    await _prefs.setBool('useCelsius', value);
    notifyListeners();
  }

  // Update data refresh interval
  Future<void> setUpdateInterval(int milliseconds) async {
    _updateInterval = milliseconds;
    await _prefs.setInt('updateInterval', milliseconds);
    notifyListeners();
  }
}
