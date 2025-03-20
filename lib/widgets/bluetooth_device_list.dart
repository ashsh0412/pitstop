import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obd_provider.dart';
import '../styles.dart';

class BluetoothDeviceList extends StatelessWidget {
  const BluetoothDeviceList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final obdProvider = Provider.of<OBDProvider>(context);

    return Column(
      children: [
        if (obdProvider.discoveredDevices.isNotEmpty) ...[
          const Row(
            children: [
              Icon(Icons.search, size: 20),
              SizedBox(width: 8),
              Text(
                'Discovered Devices',
                style: AppStyles.boldText,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...obdProvider.discoveredDevices.map(
            (device) => Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bluetooth,
                    color: Colors.blue,
                  ),
                ),
                title: Text(
                  device.platformName.isEmpty
                      ? 'Unknown Device'
                      : device.platformName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${device.remoteId}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: device.isConnected
                              ? Colors.green
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          device.isConnected ? 'Connected' : 'Not Connected',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: device.isConnected
                                        ? Colors.green
                                        : Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: ElevatedButton(
                  style: AppStyles.elevatedButtonStyle,
                  onPressed: () {
                    Navigator.pop(context);
                    if (device.isConnected) {
                      obdProvider.disconnect();
                    } else {
                      obdProvider.connect(device);
                    }
                  },
                  child: Text(
                    device.isConnected ? 'Disconnect' : 'Connect',
                  ),
                ),
              ),
            ),
          ),
        ],
        if (obdProvider.pairedDevices.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Row(
            children: [
              Icon(Icons.bluetooth_connected, size: 20),
              SizedBox(width: 8),
              Text(
                'Paired Devices',
                style: AppStyles.boldText,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...obdProvider.pairedDevices.map(
            (device) => Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bluetooth_connected,
                    color: Colors.green,
                  ),
                ),
                title: Text(
                  device.platformName.isEmpty
                      ? 'Unknown Device'
                      : device.platformName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${device.remoteId}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      style: AppStyles.elevatedButtonStyle,
                      onPressed: () {
                        Navigator.pop(context);
                        if (device.isConnected) {
                          obdProvider.disconnect();
                        } else {
                          obdProvider.connect(device);
                        }
                      },
                      child: Text(
                        device.isConnected ? 'Disconnect' : 'Connect',
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        obdProvider.unpairDevice(device);
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bluetooth_disabled,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No devices found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap "Scan for Devices" to start scanning',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
