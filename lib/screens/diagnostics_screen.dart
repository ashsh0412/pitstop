import 'package:flutter/material.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Diagnostics')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "OBD2 Error Codes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildErrorCard(
              "P0420",
              "Catalyst System Efficiency Below Threshold",
            ),
            _buildErrorCard(
              "P0300",
              "Random/Multiple Cylinder Misfire Detected",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String code, String description) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(
          code,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        subtitle: Text(description),
        trailing: Icon(Icons.warning, color: Colors.red),
      ),
    );
  }
}
