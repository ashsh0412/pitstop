import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obd_provider.dart';
import '../widgets/bluetooth_device_list.dart';
import '../models/diagnostic_code.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OBDProvider>(
      builder: (context, obdProvider, child) {
        return Scaffold(
          body: SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
              child: Column(
                children: [
                  // Connection Status
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[100],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          obdProvider.isConnected
                              ? '연결됨: ${obdProvider.deviceName}'
                              : '연결 안됨',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (obdProvider.isConnected)
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => obdProvider.disconnect(),
                          ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: obdProvider.isConnected
                        ? SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    '실시간 데이터',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  padding: const EdgeInsets.all(16),
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 1.5,
                                  children: [
                                    _buildDataCard(
                                      context,
                                      '속도',
                                      '${obdProvider.speed} km/h',
                                      Icons.speed,
                                    ),
                                    _buildDataCard(
                                      context,
                                      'RPM',
                                      '${obdProvider.rpm}',
                                      Icons.rotate_right,
                                    ),
                                    _buildDataCard(
                                      context,
                                      '엔진 온도',
                                      '${obdProvider.engineTemp}°C',
                                      Icons.thermostat,
                                    ),
                                    _buildDataCard(
                                      context,
                                      '배터리 전압',
                                      '${obdProvider.batteryVoltage}V',
                                      Icons.battery_charging_full,
                                    ),
                                    _buildDataCard(
                                      context,
                                      '연료 압력',
                                      '${obdProvider.fuelPressure} kPa',
                                      Icons.local_gas_station,
                                    ),
                                    _buildDataCard(
                                      context,
                                      '흡기 압력',
                                      '${obdProvider.intakePressure} kPa',
                                      Icons.air,
                                    ),
                                    _buildDataCard(
                                      context,
                                      '스로틀 위치',
                                      '${obdProvider.throttlePosition}%',
                                      Icons.speed,
                                    ),
                                    _buildDataCard(
                                      context,
                                      '엔진 부하',
                                      '${obdProvider.engineLoad}%',
                                      Icons.engineering,
                                    ),
                                    _buildDataCard(
                                      context,
                                      '연비',
                                      '${obdProvider.fuelEconomy.toStringAsFixed(1)} km/L',
                                      Icons.local_gas_station,
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    '진단 코드',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: obdProvider.dtc.length,
                                  itemBuilder: (context, index) {
                                    final dtc = DiagnosticCode.getByCode(
                                        obdProvider.dtc[index]);
                                    return ExpansionTile(
                                      title: Text(dtc.code),
                                      subtitle: Text(dtc.description),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('심각도: ${dtc.severity}'),
                                              const SizedBox(height: 8),
                                              Text(
                                                  '가능한 원인: ${dtc.possibleCauses.join(", ")}'),
                                              const SizedBox(height: 8),
                                              Text(
                                                  '권장 조치: ${dtc.solutions.join(", ")}'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.height -
                                MediaQuery.of(context).padding.top -
                                kToolbarHeight -
                                80, // 80 is the height of the connection status container
                            child:
                                BluetoothDeviceList(obdProvider: obdProvider),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
