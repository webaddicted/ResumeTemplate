import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:template/controller/initial_binding.dart';
import 'package:template/controller/routes.dart';
import 'package:template/controller/theme_controller.dart';
import 'package:template/global/constant/app_constant.dart';
import 'package:template/global/constant/routers_const.dart';
import 'package:template/global/theme/app_theme.dart';

void main() {
  runApp(const ResumeKitApp());
}

class ResumeKitApp extends StatelessWidget {
  const ResumeKitApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ThemeController());

    return GetMaterialApp(
      title: AppConstant.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      initialBinding: InitialBinding(),
      initialRoute: RoutersConst.initialRoute,
      getPages: routes(),
    );
  }
}
