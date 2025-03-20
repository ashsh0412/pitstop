import 'package:flutter/material.dart';

class AppStyles {
  static const TextStyle boldText = TextStyle(
    fontWeight: FontWeight.bold,
  );

  static const TextStyle mediumText = TextStyle(
    fontSize: 16,
  );

  static const TextStyle smallText = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  static ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
