import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return ListView(
          children: [
            _buildSection('Display Settings', [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable dark theme'),
                value: settings.isDarkMode,
                onChanged: (value) => settings.setDarkMode(value),
              ),
            ]),
            _buildSection('Measurement Units', [
              SwitchListTile(
                title: const Text('Use Metric System'),
                subtitle: Text(
                  settings.useMetricSystem ? 'km/h, km/L' : 'mph, mpg',
                ),
                value: settings.useMetricSystem,
                onChanged: (value) => settings.setMetricSystem(value),
              ),
              SwitchListTile(
                title: const Text('Temperature Unit'),
                subtitle: Text(
                  settings.useCelsius ? 'Celsius (°C)' : 'Fahrenheit (°F)',
                ),
                value: settings.useCelsius,
                onChanged: (value) => settings.setUseCelsius(value),
              ),
            ]),
            _buildSection('Data Update Settings', [
              ListTile(
                title: const Text('Update Interval'),
                subtitle: Text('${settings.updateInterval} ms'),
                trailing: DropdownButton<int>(
                  value: settings.updateInterval,
                  items: [
                    for (var interval in [500, 1000, 2000, 5000])
                      DropdownMenuItem(
                        value: interval,
                        child: Text('$interval ms'),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      settings.setUpdateInterval(value);
                    }
                  },
                ),
              ),
            ]),
            _buildSection('About', [
              const ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
              ListTile(
                title: const Text('Developer'),
                subtitle: const Text('Your Name'),
                onTap: () {
                  // Add developer contact or website link
                },
              ),
            ]),
          ],
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}
