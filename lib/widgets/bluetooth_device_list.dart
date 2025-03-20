import 'package:flutter/material.dart';
import '../providers/obd_provider.dart';

class BluetoothDeviceList extends StatelessWidget {
  final OBDProvider obdProvider;

  const BluetoothDeviceList({
    Key? key,
    required this.obdProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scan button
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: obdProvider.isScanning
                ? obdProvider.stopScan
                : obdProvider.startScan,
            icon: Icon(
              obdProvider.isScanning ? Icons.stop : Icons.search,
            ),
            label: Text(
              obdProvider.isScanning ? '스캔 중지' : '장치 검색',
            ),
          ),
        ),

        // Device lists
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Paired devices section
                if (obdProvider.pairedDevices.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '페어링된 장치',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: obdProvider.pairedDevices.length,
                    itemBuilder: (context, index) {
                      final device = obdProvider.pairedDevices[index];
                      return ListTile(
                        leading: const Icon(Icons.bluetooth_connected),
                        title: Text(device.name ?? '알 수 없는 장치'),
                        subtitle: Text(device.platformName),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => obdProvider.unpairDevice(device),
                        ),
                        onTap: () {
                          // Connect to the device
                          obdProvider.connect(device, useSimulator: false);
                        },
                      );
                    },
                  ),
                ],

                // Discovered devices section
                if (obdProvider.discoveredDevices.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '발견된 장치',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: obdProvider.discoveredDevices.length,
                    itemBuilder: (context, index) {
                      final device = obdProvider.discoveredDevices[index];
                      return ListTile(
                        leading: const Icon(Icons.bluetooth),
                        title: Text(device.name ?? '알 수 없는 장치'),
                        subtitle: Text(device.platformName),
                        onTap: () {
                          // Show pairing instructions
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('장치 페어링'),
                              content: const Text(
                                '장치를 페어링하려면 시스템 설정에서 블루투스 설정을 열어주세요.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('확인'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],

                // No devices message
                if (obdProvider.pairedDevices.isEmpty &&
                    obdProvider.discoveredDevices.isEmpty &&
                    !obdProvider.isScanning)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text('장치를 검색하려면 위의 버튼을 누르세요.'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
