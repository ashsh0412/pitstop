import 'package:flutter/material.dart';
import '../providers/obd_provider.dart';

class ConnectionStatusCard extends StatelessWidget {
  final OBDProvider obdProvider;

  const ConnectionStatusCard({
    super.key,
    required this.obdProvider,
  });

  @override
  Widget build(BuildContext context) {
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
            Expanded(
              child: Text(
                obdProvider.isConnected
                    ? 'Connected to ${obdProvider.deviceName}'
                    : 'Disconnected',
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
