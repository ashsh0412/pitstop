import 'package:flutter/material.dart';
import '../models/diagnostic_code.dart';
import '../providers/obd_provider.dart';

class ErrorCodesCard extends StatelessWidget {
  final OBDProvider obdProvider;

  const ErrorCodesCard({
    super.key,
    required this.obdProvider,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 1,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Error Codes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              if (obdProvider.dtc.isEmpty)
                const Text('No error codes detected')
              else
                ...obdProvider.dtc.map((code) {
                  final diagnostic = DiagnosticCode.getByCode(code);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: DiagnosticCode.getSeverityColor(
                              diagnostic.severity),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                diagnostic.code,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                diagnostic.description,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
