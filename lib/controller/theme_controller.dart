import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:template/global/base/base_controller.dart';

/// Template app ships with a single dark theme; controller keeps parity with
/// queen-ecom routing and leaves room for a light theme later.
class ThemeController extends BaseController {
  static ThemeController get to => Get.find();

  final isDark = true.obs;

  bool get isDarkMode => isDark.value;

  @override
  void onControllerInit() {
    _applySystemUI();
  }

  void _applySystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    );
  }
}
