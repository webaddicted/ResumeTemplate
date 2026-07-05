import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Template app ships with a single dark theme; controller keeps parity with
/// queen-ecom routing and leaves room for a light theme later.
class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final isDark = true.obs;

  @override
  void onInit() {
    super.onInit();
    _applySystemUI();
  }

  void _applySystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    );
  }
}
