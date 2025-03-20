import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obd_provider.dart';
import 'bluetooth_device_list.dart';

class BluetoothDeviceDialog extends StatelessWidget {
  const BluetoothDeviceDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final obdProvider = Provider.of<OBDProvider>(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.bluetooth, size: 24),
          const SizedBox(width: 8),
          Text(
            'Bluetooth Devices',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BluetoothDeviceList(),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: obdProvider.isScanning
                    ? obdProvider.stopScan
                    : obdProvider.startScan,
                icon: Icon(
                  obdProvider.isScanning ? Icons.stop : Icons.search,
                ),
                label: Text(
                  obdProvider.isScanning ? 'Stop Scanning' : 'Scan for Devices',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
