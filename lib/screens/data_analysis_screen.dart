import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/vehicle_analysis_provider.dart';
import '../providers/settings_provider.dart';

class DataAnalysisScreen extends StatefulWidget {
  const DataAnalysisScreen({super.key});

  @override
  State<DataAnalysisScreen> createState() => _DataAnalysisScreenState();
}

class _DataAnalysisScreenState extends State<DataAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    // Fix BuildContext async gap issue
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<VehicleAnalysisProvider>(
          context,
          listen: false,
        ).generateMockData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Analysis'), elevation: 0),
      body: Consumer2<VehicleAnalysisProvider, SettingsProvider>(
        builder: (context, analysis, settings, child) {
          final data = analysis.last24Hours;

          if (data.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCard(analysis, settings),
                  const SizedBox(height: 20),
                  _buildSpeedChart(data, settings),
                  const SizedBox(height: 20),
                  _buildFuelEfficiencyChart(data, settings),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(
    VehicleAnalysisProvider analysis,
    SettingsProvider settings,
  ) {
    String formatSpeed(double speed) {
      return settings.useMetricSystem
          ? '${speed.toStringAsFixed(1)} km/h'
          : '${(speed * 0.621371).toStringAsFixed(1)} mph';
    }

    String formatFuelEfficiency(double efficiency) {
      return settings.useMetricSystem
          ? '${efficiency.toStringAsFixed(1)} km/L'
          : '${(efficiency * 2.35215).toStringAsFixed(1)} mpg';
    }

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(
        red: 0,
        green: 0,
        blue: 0,
        alpha: 26,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Driving Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _buildStatRow('Average Speed', formatSpeed(analysis.averageSpeed)),
            _buildStatRow('Max Speed', formatSpeed(analysis.maxSpeed)),
            _buildStatRow(
              'Average Fuel Efficiency',
              formatFuelEfficiency(analysis.averageFuelEfficiency),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedChart(
    List<VehicleAnalysisData> data,
    SettingsProvider settings,
  ) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(
        red: 0,
        green: 0,
        blue: 0,
        alpha: 26,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Speed Over Time',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: Text(
                        settings.useMetricSystem ? 'km/h' : 'mph',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      sideTitles: const SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots:
                          data.asMap().entries.map((entry) {
                            final speed =
                                settings.useMetricSystem
                                    ? entry.value.speed
                                    : entry.value.speed * 0.621371;
                            return FlSpot(entry.key.toDouble(), speed);
                          }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelEfficiencyChart(
    List<VehicleAnalysisData> data,
    SettingsProvider settings,
  ) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(
        red: 0,
        green: 0,
        blue: 0,
        alpha: 26,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fuel Efficiency Over Time',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: Text(
                        settings.useMetricSystem ? 'km/L' : 'mpg',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      sideTitles: const SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots:
                          data.asMap().entries.map((entry) {
                            final efficiency =
                                settings.useMetricSystem
                                    ? entry.value.fuelEfficiency
                                    : entry.value.fuelEfficiency * 2.35215;
                            return FlSpot(entry.key.toDouble(), efficiency);
                          }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
