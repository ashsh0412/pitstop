import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obd_provider.dart';
import '../providers/settings_provider.dart';
import 'diagnostics_screen.dart';
import 'maintenance_screen.dart';
import 'settings_screen.dart';
import '../models/diagnostic_code.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Bluetooth Devices'),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Consumer<OBDProvider>(
                      builder: (context, obdProvider, child) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: obdProvider.isScanning
                                      ? obdProvider.stopScan
                                      : obdProvider.startScan,
                                  icon: Icon(
                                    obdProvider.isScanning
                                        ? Icons.stop
                                        : Icons.search,
                                  ),
                                  label: Text(
                                    obdProvider.isScanning
                                        ? 'Stop Scan'
                                        : 'Scan for Devices',
                                  ),
                                ),
                                if (obdProvider.isScanning)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (obdProvider
                                        .discoveredDevices.isNotEmpty) ...[
                                      const Text(
                                        'Discovered Devices:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...obdProvider.discoveredDevices.map(
                                        (device) => Card(
                                          child: ListTile(
                                            leading:
                                                const Icon(Icons.bluetooth),
                                            title: Text(
                                              device.platformName ??
                                                  'Unknown Device',
                                            ),
                                            subtitle: Text(
                                              device.remoteId.toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            trailing: ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                obdProvider.connect(device);
                                              },
                                              child: const Text('Connect'),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (obdProvider
                                        .pairedDevices.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Paired Devices:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...obdProvider.pairedDevices.map(
                                        (device) => Card(
                                          child: ListTile(
                                            leading: const Icon(
                                              Icons.bluetooth_connected,
                                              color: Colors.blue,
                                            ),
                                            title: Text(
                                              device.platformName ??
                                                  'Unknown Device',
                                            ),
                                            subtitle: Text(
                                              device.remoteId.toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    obdProvider.connect(device);
                                                  },
                                                  child: const Text('Connect'),
                                                ),
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.delete),
                                                  onPressed: () {
                                                    obdProvider
                                                        .unpairDevice(device);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (!obdProvider.isScanning &&
                                        obdProvider.discoveredDevices.isEmpty &&
                                        obdProvider.pairedDevices.isEmpty)
                                      const Center(
                                        child: Text(
                                          'No devices found.\nTap "Scan for Devices" to start scanning.',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _DashboardContent(),
          DiagnosticsScreen(),
          MaintenanceScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Diagnostics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Maintenance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _showConnectionDialog(BuildContext context) {
    final obdProvider = Provider.of<OBDProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(obdProvider.isConnected ? 'Connected' : 'Disconnected'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Status: ${obdProvider.isConnected ? 'Connected' : 'Disconnected'}'),
            if (obdProvider.isConnected) ...[
              const SizedBox(height: 8),
              Text('Device: ${obdProvider.deviceName}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!obdProvider.isConnected)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (obdProvider.pairedDevices.isNotEmpty) {
                  obdProvider.connect(obdProvider.pairedDevices[0]);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'No paired devices available. Please pair a device first.'),
                    ),
                  );
                }
              },
              child: const Text('Connect'),
            ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Diagnostics';
      case 2:
        return 'Maintenance';
      case 3:
        return 'Settings';
      default:
        return 'Vehicle Diagnostics';
    }
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final obdProvider = Provider.of<OBDProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConnectionStatus(context, obdProvider),
          const SizedBox(height: 24),
          _buildRealTimeData(context, obdProvider, settingsProvider),
          const SizedBox(height: 24),
          _buildErrorCodes(context, obdProvider),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context, OBDProvider obdProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              obdProvider.isConnected
                  ? Icons.bluetooth_connected
                  : Icons.bluetooth_disabled,
              color: obdProvider.isConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              obdProvider.isConnected ? 'Connected to OBD' : 'Disconnected',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTimeData(BuildContext context, OBDProvider obdProvider,
      SettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Real-time Data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildDataRow('Speed',
                '${obdProvider.speed} ${settingsProvider.useMetricSystem ? 'km/h' : 'mph'}'),
            _buildDataRow('RPM', '${obdProvider.rpm}'),
            _buildDataRow('Engine Temp',
                '${obdProvider.engineTemp}°${settingsProvider.useCelsius ? 'C' : 'F'}'),
            _buildDataRow('Battery', '${obdProvider.batteryVoltage}V'),
            _buildDataRow('Fuel Pressure', '${obdProvider.fuelPressure} kPa'),
            _buildDataRow(
                'Intake Pressure', '${obdProvider.intakePressure} kPa'),
            _buildDataRow('Throttle', '${obdProvider.throttlePosition}%'),
            _buildDataRow('Engine Load', '${obdProvider.engineLoad}%'),
            _buildDataRow('Fuel Economy',
                '${obdProvider.fuelEconomy} ${settingsProvider.useMetricSystem ? 'km/L' : 'mpg'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCodes(BuildContext context, OBDProvider obdProvider) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 1,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Error Codes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              if (obdProvider.dtc.isEmpty)
                const Text('No error codes detected')
              else
                ...obdProvider.dtc.map((code) {
                  final diagnostic = DiagnosticCode.getByCode(code);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: DiagnosticCode.getSeverityColor(
                              diagnostic.severity),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                diagnostic.code,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                diagnostic.description,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
