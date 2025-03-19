import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/diagnostics_provider.dart';
import '../providers/vehicle_state_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<DiagnosticsProvider, VehicleStateProvider>(
      builder: (context, diagnosticsProvider, vehicleState, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Diagnostics'),
            actions: [
              Switch(
                value: diagnosticsProvider.isConnected,
                onChanged: (value) => diagnosticsProvider.toggleConnection(),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  if (vehicleState.canUseDiagnostics()) {
                    diagnosticsProvider.refreshDTCs();
                  } else {
                    _showDrivingModeDialog(context);
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatusCard(
                      context,
                      icon: Icons.error,
                      label: 'Critical',
                      count: diagnosticsProvider.criticalCount,
                      color: Colors.red,
                    ),
                    _buildStatusCard(
                      context,
                      icon: Icons.warning,
                      label: 'Warning',
                      count: diagnosticsProvider.warningCount,
                      color: Colors.orange,
                    ),
                    _buildStatusCard(
                      context,
                      icon: Icons.info,
                      label: 'Info',
                      count: diagnosticsProvider.infoCount,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Diagnostic Trouble Codes (DTC)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child:
                    diagnosticsProvider.dtcs.isEmpty
                        ? const Center(
                          child: Text('No diagnostic trouble codes found'),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: diagnosticsProvider.dtcs.length,
                          itemBuilder: (context, index) {
                            final dtc = diagnosticsProvider.dtcs[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ExpansionTile(
                                leading: Icon(
                                  _getSeverityIcon(dtc.severity),
                                  color: _getSeverityColor(dtc.severity),
                                ),
                                title: Text(dtc.code),
                                subtitle: Text(dtc.description),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Severity: ${dtc.severity.name}'),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Possible causes: ${dtc.possibleCauses}',
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Solutions: ${dtc.solutions}'),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton.icon(
                                              icon: const Icon(Icons.search),
                                              label: const Text(
                                                'Search Online',
                                              ),
                                              onPressed:
                                                  () => _searchDTCOnline(
                                                    dtc.code,
                                                  ),
                                            ),
                                            ElevatedButton.icon(
                                              icon: const Icon(Icons.build),
                                              label: const Text(
                                                'Find Mechanic',
                                              ),
                                              onPressed: _findNearbyMechanic,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
          floatingActionButton:
              vehicleState.canUseDiagnostics()
                  ? FloatingActionButton(
                    onPressed: () {
                      if (diagnosticsProvider.isConnected) {
                        _showClearDTCDialog(context, diagnosticsProvider);
                      } else {
                        _showConnectDialog(context);
                      }
                    },
                    child: const Icon(Icons.cleaning_services),
                  )
                  : null,
        );
      },
    );
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 48) / 3,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSeverityIcon(DTCSeverity severity) {
    switch (severity) {
      case DTCSeverity.critical:
        return Icons.error;
      case DTCSeverity.warning:
        return Icons.warning;
      case DTCSeverity.info:
        return Icons.info;
    }
  }

  Color _getSeverityColor(DTCSeverity severity) {
    switch (severity) {
      case DTCSeverity.critical:
        return Colors.red;
      case DTCSeverity.warning:
        return Colors.orange;
      case DTCSeverity.info:
        return Colors.blue;
    }
  }

  Future<void> _searchDTCOnline(String dtcCode) async {
    final url = Uri.parse(
      'https://www.google.com/search?q=OBD2+${Uri.encodeComponent(dtcCode)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _findNearbyMechanic() async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/auto+repair+shop+near+me',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showDrivingModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('주행 중 제한'),
            content: const Text('안전을 위해 주행 중에는 진단 기능을 사용할 수 없습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  void _showClearDTCDialog(BuildContext context, DiagnosticsProvider provider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('DTC 초기화'),
            content: const Text('저장된 모든 진단 코드를 초기화하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  final success = provider.clearDTCs();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'DTC 초기화 완료' : 'DTC 초기화 실패'),
                    ),
                  );
                },
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  void _showConnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('연결 필요'),
            content: const Text('DTC를 초기화하려면 먼저 OBD2 어댑터에 연결하세요.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }
}
