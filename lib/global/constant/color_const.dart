import 'package:flutter/material.dart';

class ColorConst {
  static const Color appColor = Color(0xFFCE8946);
  static const Color primaryColor = Color(0xFFCE8946);
  static const Color secondaryColor = Color(0xFFAD56C4);

  static const Color transparentColor = Color(0x00000000);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF000000);
  static const Color greyColor = Color(0xFF9CA3AF);
  static const Color redColor = Color(0xFFE35336);
  static const Color greenColor = Color(0xFF519755);

  static Color yellowColor = Colors.amberAccent;

  static const Color colorFF0A0E21 = Color(0xFF0A0E21);
  static const Color colorFF1D1E33 = Color(0xFF1D1E33);
  static const Color colorFF374151 = Color(0xFF374151);
  static const Color colorFF1E1E1E = Color(0xFF1E1E1E);
  static const Color colorFF111328 = Color(0xFF111328);
  static const Color colorFF3B82F6 = Color(0xFFCE8946);
  static const Color colorFF0066FF = Color(0xFFCE8946);
  static const Color colorFF818CF8 = Color(0xFF818CF8);
  static const Color colorFF9CA3AF = Color(0xFF9CA3AF);
  static const Color colorFFFFFFFF = Color(0xFFFFFFFF);
  static const Color colorFFEF4444 = Color(0xFFEF4444);
  static const Color colorFF4CAF50 = Color(0xFF4CAF50);
  static const Color colorFFF44336 = Color(0xFFF44336);
  static const Color colorFFFF9800 = Color(0xFFFF9800);
  static const Color colorFF2196F3 = Color(0xFF2196F3);
  static const Color colorFFF5F5F5 = Color(0xFFF5F5F5);
  static const Color colorFF9C27B0 = Color(0xFF9C27B0);

  static Color whiteBgColor = Colors.white;
  static Color white = Colors.white;
}

Color colorFromHex(String hexColor) {
  final hex = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hex', radix: 16));
}
