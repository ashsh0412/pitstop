import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/vehicle_data_provider.dart';
import 'providers/vehicle_analysis_provider.dart';
import 'providers/diagnostics_provider.dart';
import 'providers/vehicle_state_provider.dart';
import 'providers/vehicle_alert_provider.dart';
import 'providers/vehicle_provider.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/data_analysis_screen.dart';
import 'screens/diagnostics_screen.dart';
import 'screens/vehicle_management_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => settingsProvider),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => VehicleDataProvider()),
        ChangeNotifierProvider(create: (_) => VehicleAnalysisProvider()),
        ChangeNotifierProvider(create: (_) => DiagnosticsProvider()),
        ChangeNotifierProvider(create: (_) => VehicleStateProvider()),
        ChangeNotifierProvider(create: (_) => VehicleAlertProvider()),
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
      builder: (context, settings, _) {
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
          initialRoute: '/vehicles',
          routes: {
            '/': (context) => const HomeScreen(),
            '/vehicles': (context) => const VehicleManagementScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/analysis': (context) => const DataAnalysisScreen(),
            '/diagnostics': (context) => const DiagnosticsScreen(),
          },
        );
      },
    );
  }
}
