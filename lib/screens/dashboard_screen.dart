import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/vehicle_data_provider.dart';

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
    _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      Provider.of<VehicleDataProvider>(context, listen: false).updateMockData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Dashboard', style: GoogleFonts.orbitron()),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Consumer<VehicleDataProvider>(
        builder: (context, provider, child) {
          final data = provider.data;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue, Colors.blue.shade900],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
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
                  SizedBox(height: 20),
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
                          "${data.speed.toStringAsFixed(1)} km/h",
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
                          "${data.fuelEfficiency.toStringAsFixed(1)} km/L",
                          Icons.local_gas_station,
                          Colors.orange,
                        ),
                        _buildDataCard(
                          "Engine Temp",
                          "${data.engineTemp.toStringAsFixed(1)}°C",
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
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
