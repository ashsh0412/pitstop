import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obd_provider.dart';
import '../widgets/bluetooth_device_dialog.dart';
import '../widgets/bluetooth_device_list.dart';
import '../models/diagnostic_code.dart';
import '../widgets.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final obdProvider = Provider.of<OBDProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.bluetooth,
              color: obdProvider.isConnected ? Colors.blue : Colors.grey,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const BluetoothDeviceDialog(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.bluetooth,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Bluetooth Devices',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.95,
                            height: MediaQuery.of(context).size.height * 0.8,
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Bluetooth Devices',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                const Divider(height: 32),
                                Consumer<OBDProvider>(
                                  builder: (context, obdProvider, child) {
                                    return Expanded(
                                      child: Column(
                                        children: [
                                          Center(
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 32,
                                                  vertical: 16,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: () {
                                                if (obdProvider.isScanning) {
                                                  obdProvider.stopScan();
                                                } else {
                                                  obdProvider.startScan();
                                                }
                                              },
                                              icon: Icon(
                                                obdProvider.isScanning
                                                    ? Icons.stop
                                                    : Icons.search,
                                                size: 28,
                                              ),
                                              label: Text(
                                                obdProvider.isScanning
                                                    ? 'Stop Scan'
                                                    : 'Scan for Devices',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ),
                                          if (obdProvider.isScanning)
                                            const Padding(
                                              padding: EdgeInsets.all(24.0),
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                          const SizedBox(height: 24),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (obdProvider
                                                      .discoveredDevices
                                                      .isNotEmpty) ...[
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.search,
                                                            size: 20),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                          'Discovered Devices',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleMedium
                                                                  ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                    ...obdProvider
                                                        .discoveredDevices
                                                        .map(
                                                      (device) => Card(
                                                        elevation: 2,
                                                        margin: const EdgeInsets
                                                            .only(bottom: 12),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: ListTile(
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 16,
                                                            vertical: 8,
                                                          ),
                                                          leading: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.blue
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: const Icon(
                                                              Icons.bluetooth,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                          ),
                                                          title: Text(
                                                            device.platformName
                                                                    .isEmpty
                                                                ? 'Unknown Device'
                                                                : device
                                                                    .platformName,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          subtitle: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                'ID: ${device.remoteId}',
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall,
                                                              ),
                                                              const SizedBox(
                                                                  height: 2),
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .circle,
                                                                    size: 12,
                                                                    color: device
                                                                            .isConnected
                                                                        ? Colors
                                                                            .green
                                                                        : Theme.of(context).brightness ==
                                                                                Brightness.dark
                                                                            ? Colors.grey[400]
                                                                            : Colors.grey[600],
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 4),
                                                                  Text(
                                                                    device.isConnected
                                                                        ? 'Connected'
                                                                        : 'Not Connected',
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodySmall
                                                                        ?.copyWith(
                                                                          color: device.isConnected
                                                                              ? Colors.green
                                                                              : Theme.of(context).brightness == Brightness.dark
                                                                                  ? Colors.grey[400]
                                                                                  : Colors.grey[600],
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          trailing:
                                                              ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              backgroundColor:
                                                                  device.isConnected
                                                                      ? Colors
                                                                          .red
                                                                      : null,
                                                            ),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                              if (device
                                                                  .isConnected) {
                                                                obdProvider
                                                                    .disconnect();
                                                              } else {
                                                                obdProvider
                                                                    .connect(
                                                                        device);
                                                              }
                                                            },
                                                            child: Text(
                                                              device.isConnected
                                                                  ? 'Disconnect'
                                                                  : 'Connect',
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  if (obdProvider.pairedDevices
                                                      .isNotEmpty) ...[
                                                    const SizedBox(height: 24),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                            Icons
                                                                .bluetooth_connected,
                                                            size: 20),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                          'Paired Devices',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleMedium
                                                                  ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                    ...obdProvider.pairedDevices
                                                        .map(
                                                      (device) => Card(
                                                        elevation: 2,
                                                        margin: const EdgeInsets
                                                            .only(bottom: 12),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: ListTile(
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 16,
                                                            vertical: 8,
                                                          ),
                                                          leading: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .green
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: const Icon(
                                                              Icons
                                                                  .bluetooth_connected,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          ),
                                                          title: Text(
                                                            device.platformName
                                                                    .isEmpty
                                                                ? 'Unknown Device'
                                                                : device
                                                                    .platformName,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          subtitle: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                'ID: ${device.remoteId}',
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall,
                                                              ),
                                                            ],
                                                          ),
                                                          trailing: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  backgroundColor:
                                                                      device.isConnected
                                                                          ? Colors
                                                                              .red
                                                                          : null,
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  if (device
                                                                      .isConnected) {
                                                                    obdProvider
                                                                        .disconnect();
                                                                  } else {
                                                                    obdProvider
                                                                        .connect(
                                                                            device);
                                                                  }
                                                                },
                                                                child: Text(
                                                                  device.isConnected
                                                                      ? 'Disconnect'
                                                                      : 'Connect',
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 8),
                                                              IconButton(
                                                                icon:
                                                                    const Icon(
                                                                  Icons
                                                                      .delete_outline,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                                onPressed: () {
                                                                  obdProvider
                                                                      .unpairDevice(
                                                                          device);
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  if (!obdProvider.isScanning &&
                                                      obdProvider
                                                          .discoveredDevices
                                                          .isEmpty &&
                                                      obdProvider.pairedDevices
                                                          .isEmpty)
                                                    Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .bluetooth_disabled,
                                                            size: 48,
                                                            color: Colors
                                                                .grey[400],
                                                          ),
                                                          const SizedBox(
                                                              height: 16),
                                                          Text(
                                                            'No devices found',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleMedium
                                                                ?.copyWith(
                                                                  color: Colors
                                                                          .grey[
                                                                      600],
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            'Tap "Scan for Devices" to start scanning',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.copyWith(
                                                                  color: Colors
                                                                          .grey[
                                                                      500],
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (obdProvider.isConnected) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Diagnostic Trouble Codes (DTC)',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (obdProvider.dtc.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 40,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 48,
                                  color: Colors.green.withOpacity(0.8),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No diagnostic trouble codes found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: obdProvider.dtc.length,
                            itemBuilder: (context, index) {
                              final code = obdProvider.dtc[index];
                              final diagnostic = DiagnosticCode.getByCode(code);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    elevation: 0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color:
                                                DiagnosticCode.getSeverityColor(
                                                        diagnostic.severity)
                                                    .withOpacity(0.1),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: DiagnosticCode
                                                    .getSeverityColor(
                                                        diagnostic.severity),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  diagnostic.code,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                diagnostic.description,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 3,
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12),
                                                child: Divider(),
                                              ),
                                              _buildDetailSection(
                                                'Possible Causes:',
                                                diagnostic.possibleCauses
                                                    .join(", "),
                                                Icons.help_outline,
                                              ),
                                              const SizedBox(height: 16),
                                              _buildDetailSection(
                                                'Recommended Solutions:',
                                                diagnostic.solutions.join(", "),
                                                Icons.build_outlined,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.grey[800],
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 4,
        ),
      ],
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
