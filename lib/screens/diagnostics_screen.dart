import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obd_provider.dart';
import '../models/diagnostic_code.dart';
import '../widgets/connection_status_card.dart';
import '../widgets/error_codes_card.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final obdProvider = Provider.of<OBDProvider>(context);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConnectionStatusCard(obdProvider: obdProvider),
          ),
          // Bluetooth Connection Status Header
          // Diagnostic Data Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (obdProvider.isConnected) ...[
                    if (obdProvider.dtc.isEmpty)
                      ErrorCodesCard(obdProvider: obdProvider)
                    else
                      _buildDiagnosticList(obdProvider),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticList(OBDProvider obdProvider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: obdProvider.dtc.length,
      itemBuilder: (context, index) {
        final code = obdProvider.dtc[index];
        final diagnostic = DiagnosticCode.getByCode(code);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          DiagnosticCode.getSeverityColor(diagnostic.severity)
                              .withOpacity(0.1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: DiagnosticCode.getSeverityColor(
                              diagnostic.severity),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            diagnostic.code,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diagnostic.description,
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(),
                        ),
                        _buildDetailSection(
                          'Possible Causes:',
                          diagnostic.possibleCauses.join(", "),
                          Icons.warning,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailSection(
                          'Recommended Fixes:',
                          diagnostic.solutions.join(", "),
                          Icons.settings_suggest_outlined,
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
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 22, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style:
              const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
          overflow: TextOverflow.ellipsis,
          maxLines: 4,
        ),
      ],
    );
  }
}
