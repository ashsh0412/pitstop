import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obd_provider.dart';
import '../providers/settings_provider.dart';
import 'diagnostics_screen.dart';
import 'maintenance_screen.dart';
import 'settings_screen.dart';
import '../widgets/connection_status_card.dart';
import '../widgets/error_codes_card.dart';
import '../widgets/bluetooth_dialog.dart';
import '../widgets/bluetooth_required_message.dart';

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
        title: Text(_getTitle()),
        actions: [
          Consumer<OBDProvider>(
            builder: (context, obdProvider, child) {
              return IconButton(
                icon: Icon(
                  Icons.bluetooth,
                  color: obdProvider.isConnected ? Colors.blue : Colors.grey,
                ),
                onPressed: () {
                  _showBluetoothDialog(context, obdProvider);
                },
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _DashboardContent(), // ✅ 기존 대시보드 콘텐츠 유지
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

  // 🔥 선택된 페이지에 따라 동적으로 앱 타이틀 변경
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

  // 📡 블루투스 모달 창 표시
  void _showBluetoothDialog(BuildContext context, OBDProvider obdProvider) {
    showDialog(
      context: context,
      builder: (context) => BluetoothDialog(obdProvider: obdProvider),
    );
  }
}

// ✅ **기존 `_DashboardContent` 유지**
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
          ConnectionStatusCard(obdProvider: obdProvider),
          if (!obdProvider.isConnected)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: BluetoothRequiredMessage(
                message: 'OBD 기기를 연결하여 차량 상태를 확인하세요',
                obdProvider: obdProvider,
              ),
            )
          else ...[
            const SizedBox(height: 24),
            _buildRealTimeData(context, obdProvider, settingsProvider),
            const SizedBox(height: 24),
            ErrorCodesCard(obdProvider: obdProvider),
            const SizedBox(height: 24),
            if (obdProvider.diagnosticCodes.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diagnostic Trouble Codes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      ...obdProvider.diagnosticCodes.map((code) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.orange),
                                const SizedBox(width: 8),
                                Text(code.code),
                                const SizedBox(width: 16),
                                Expanded(child: Text(code.description)),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
          ],
        ],
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
}
