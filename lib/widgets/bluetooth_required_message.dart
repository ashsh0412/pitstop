import 'package:flutter/material.dart';
import '../providers/obd_provider.dart';
import 'bluetooth_dialog.dart';

class BluetoothRequiredMessage extends StatelessWidget {
  final String message;
  final OBDProvider obdProvider;

  const BluetoothRequiredMessage({
    super.key,
    required this.message,
    required this.obdProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (obdProvider.isConnecting) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              '블루투스 연결 중...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.blue,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '잠시만 기다려주세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ] else ...[
            Icon(
              Icons.bluetooth_disabled,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '블루투스 연결이 필요합니다',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.bluetooth_searching),
              label: const Text('블루투스 연결하기'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      BluetoothDialog(obdProvider: obdProvider),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
