import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/vehicle_data_provider.dart';
import '../providers/settings_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      if (mounted) {
        Provider.of<VehicleDataProvider>(
          context,
          listen: false,
        ).updateMockData();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatSpeed(double speed, bool useMetric) {
    if (useMetric) {
      return '${speed.toStringAsFixed(1)} km/h';
    } else {
      return '${(speed * 0.621371).toStringAsFixed(1)} mph';
    }
  }

  String _formatTemperature(double temp, bool useCelsius) {
    if (useCelsius) {
      return '${temp.toStringAsFixed(1)}°C';
    } else {
      return '${(temp * 9 / 5 + 32).toStringAsFixed(1)}°F';
    }
  }

  String _formatFuelEfficiency(double efficiency, bool useMetric) {
    if (useMetric) {
      return '${efficiency.toStringAsFixed(1)} km/L';
    } else {
      return '${(efficiency * 2.35215).toStringAsFixed(1)} mpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Dashboard', style: GoogleFonts.orbitron()),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Consumer2<VehicleDataProvider, SettingsProvider>(
        builder: (context, vehicleData, settings, child) {
          final data = vehicleData.data;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue, Colors.blue.shade900],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Real-time Vehicle Data",
                    style: GoogleFonts.orbitron(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildDataCard(
                          "RPM",
                          data.rpm.toStringAsFixed(0),
                          Icons.speed,
                          Colors.red,
                        ),
                        _buildDataCard(
                          "Speed",
                          _formatSpeed(data.speed, settings.useMetricSystem),
                          Icons.directions_car,
                          Colors.green,
                        ),
                        _buildDataCard(
                          "Battery",
                          "${data.voltage.toStringAsFixed(1)}V",
                          Icons.battery_charging_full,
                          Colors.blue,
                        ),
                        _buildDataCard(
                          "Fuel Efficiency",
                          _formatFuelEfficiency(
                            data.fuelEfficiency,
                            settings.useMetricSystem,
                          ),
                          Icons.local_gas_station,
                          Colors.orange,
                        ),
                        _buildDataCard(
                          "Engine Temp",
                          _formatTemperature(
                            data.engineTemp,
                            settings.useCelsius,
                          ),
                          Icons.thermostat,
                          Colors.red,
                        ),
                        _buildDataCard(
                          "Throttle",
                          "${data.throttlePosition.toStringAsFixed(1)}%",
                          Icons.speed,
                          Colors.purple,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              red: 0,
              green: 0,
              blue: 0,
              alpha: 26,
            ),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.orbitron(
                fontSize: 20,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
