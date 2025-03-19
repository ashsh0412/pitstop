import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_state_provider.dart';
import '../providers/vehicle_alert_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<VehicleStateProvider, VehicleAlertProvider>(
      builder: (context, vehicleState, alertProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              vehicleState.currentState == VehicleState.parked
                  ? '차량 정비 모드'
                  : '주행 모드',
            ),
            actions: [
              IconButton(
                icon: Icon(
                  alertProvider.isVoiceAlertEnabled
                      ? Icons.volume_up
                      : Icons.volume_off,
                ),
                onPressed: alertProvider.toggleVoiceAlert,
                tooltip:
                    '음성 알림 ${alertProvider.isVoiceAlertEnabled ? "켜짐" : "꺼짐"}',
              ),
            ],
          ),
          body: Column(
            children: [
              _buildStateIndicator(vehicleState),
              _buildAlertList(alertProvider),
              Expanded(
                child:
                    vehicleState.currentState == VehicleState.parked
                        ? _buildParkedModeFeatures(context)
                        : _buildDrivingModeFeatures(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStateIndicator(VehicleStateProvider state) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color:
          state.currentState == VehicleState.parked
              ? Colors.blue.withOpacity(0.1)
              : Colors.green.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            state.currentState == VehicleState.parked
                ? Icons.garage
                : Icons.drive_eta,
            color:
                state.currentState == VehicleState.parked
                    ? Colors.blue
                    : Colors.green,
          ),
          const SizedBox(width: 8),
          Text(
            state.currentState == VehicleState.parked ? '정차 상태' : '주행 중',
            style: TextStyle(
              color:
                  state.currentState == VehicleState.parked
                      ? Colors.blue
                      : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (state.isEngineOn) ...[
            const SizedBox(width: 16),
            const Icon(Icons.local_gas_station, color: Colors.orange),
            const SizedBox(width: 4),
            Text(
              '엔진 ON',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertList(VehicleAlertProvider alertProvider) {
    if (alertProvider.alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 100,
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: alertProvider.alerts.length,
        itemBuilder: (context, index) {
          final alert = alertProvider.alerts[index];
          return Card(
            color: _getAlertColor(alert.severity).withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getAlertIcon(alert.severity),
                        color: _getAlertColor(alert.severity),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        alert.title,
                        style: TextStyle(
                          color: _getAlertColor(alert.severity),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildParkedModeFeatures(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      children: [
        _buildFeatureCard(
          context,
          icon: Icons.bluetooth,
          title: 'OBD2 연결',
          onTap: () {
            // TODO: OBD2 연결 화면으로 이동
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.build,
          title: '차량 진단',
          onTap: () {
            Navigator.pushNamed(context, '/diagnostics');
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.calendar_today,
          title: '유지보수 알림',
          onTap: () {
            // TODO: 유지보수 알림 화면으로 이동
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.history,
          title: '운행 기록',
          onTap: () {
            Navigator.pushNamed(context, '/analysis');
          },
        ),
      ],
    );
  }

  Widget _buildDrivingModeFeatures(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      children: [
        _buildFeatureCard(
          context,
          icon: Icons.speed,
          title: '실시간 데이터',
          onTap: () {
            Navigator.pushNamed(context, '/dashboard');
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.warning,
          title: '경고 내역',
          onTap: () {
            // TODO: 경고 내역 화면으로 이동
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAlertColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Colors.red;
      case AlertSeverity.warning:
        return Colors.orange;
      case AlertSeverity.info:
        return Colors.blue;
    }
  }

  IconData _getAlertIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Icons.error;
      case AlertSeverity.warning:
        return Icons.warning;
      case AlertSeverity.info:
        return Icons.info;
    }
  }
}
