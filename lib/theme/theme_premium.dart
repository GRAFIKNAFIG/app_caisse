import 'package:flutter/material.dart';

class PremiumTheme {
  static const Color background = Color(0xFFF5F5F5);
  static const Color panelBackground = Colors.white;
  static const Color panelSelected = Color(0xFFE0E0E0);

  static const TextStyle title = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle label = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const TextStyle text = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle totalText = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static final BoxDecoration panelDecoration = BoxDecoration(
    color: panelBackground,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  );
}
