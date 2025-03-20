import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiagnosticCode {
  final String code;
  final String description;
  final String severity;
  final String details;
  final List<String> possibleCauses;
  final List<String> solutions;

  const DiagnosticCode({
    required this.code,
    required this.description,
    required this.severity,
    required this.details,
    required this.possibleCauses,
    required this.solutions,
  });

  factory DiagnosticCode.fromJson(Map<String, dynamic> json) {
    return DiagnosticCode(
      code: json['code'],
      description: json['description'],
      severity: json['severity'],
      details: json['details'],
      possibleCauses: List<String>.from(json['possibleCauses']),
      solutions: List<String>.from(json['solutions']),
    );
  }

  static Map<String, DiagnosticCode> _codes = {};
  static bool _isLoaded = false;

  static Future<void> loadCodes() async {
    if (_isLoaded) return;

    try {
      final String jsonString =
          await rootBundle.loadString('assets/dtc_codes.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _codes = jsonData
          .map((key, value) => MapEntry(key, DiagnosticCode.fromJson(value)));

      _isLoaded = true;
    } catch (e) {
      print('Error loading diagnostic codes: $e');
    }
  }

  // 코드로 진단 정보 찾기
  static DiagnosticCode getByCode(String code) {
    if (!_isLoaded) {
      loadCodes();
    }
    return _codes[code] ??
        DiagnosticCode(
          code: code,
          description: 'Unknown Error Code',
          severity: 'unknown',
          details: 'No detailed information available for this error code.',
          possibleCauses: [],
          solutions: [],
        );
  }

  // 심각도에 따른 색상 정보
  static Color getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  // 심각도 텍스트 변환
  static String getSeverityText(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return 'High Priority';
      case 'medium':
        return 'Medium Priority';
      case 'low':
        return 'Low Priority';
      default:
        return 'Unknown Priority';
    }
  }
}
