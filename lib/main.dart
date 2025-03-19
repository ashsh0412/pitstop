import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/vehicle_data_provider.dart';
import 'providers/vehicle_analysis_provider.dart';
import 'providers/diagnostics_provider.dart';
import 'providers/maintenance_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/data_analysis_screen.dart';
import 'screens/diagnostics_screen.dart';
import 'screens/maintenance_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(create: (_) => VehicleDataProvider()),
        ChangeNotifierProvider(create: (_) => VehicleAnalysisProvider()),
        ChangeNotifierProvider(create: (_) => DiagnosticsProvider()),
        ChangeNotifierProvider(create: (_) => MaintenanceProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Pitstop',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness:
                  settings.isDarkMode ? Brightness.dark : Brightness.light,
            ),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const DashboardScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/analysis': (context) => const DataAnalysisScreen(),
            '/diagnostics': (context) => const DiagnosticsScreen(),
            '/maintenance': (context) =>
                const MaintenanceScreen(vehicleId: 1), // 임시로 vehicleId를 1로 설정
          },
        );
      },
    );
  }
}
