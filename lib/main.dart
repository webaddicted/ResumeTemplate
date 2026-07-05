import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:template/controller/initial_binding.dart';
import 'package:template/controller/routes.dart';
import 'package:template/controller/theme_controller.dart';
import 'package:template/global/constant/app_constant.dart';
import 'package:template/global/constant/routers_const.dart';
import 'package:template/global/services/encryption_service.dart';
import 'package:template/global/sp/encrypted_sp_helper.dart';
import 'package:template/global/sp/sp_helper.dart';
import 'package:template/global/theme/app_theme.dart';
import 'package:template/global/utils/global_utility.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/env', isOptional: true);
  await initSDK();
  runApp(const ResumeKitApp());
}

Future<void> initSDK() async {
  await SPHelper.init();
  await EncryptionService().init();
  await EncryptedSpHelper.init();

  try {
    final info = await PackageInfo.fromPlatform();
    AppConstant.setAppVersionFromPackage(info.version, info.buildNumber);
  } catch (e) {
    printLog(msg: 'PackageInfo error: $e');
  }
}

class ResumeKitApp extends StatelessWidget {
  const ResumeKitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      init: ThemeController(),
      builder: (_) => GetMaterialApp(
        title: AppConstant.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        initialBinding: InitialBinding(),
        initialRoute: RoutersConst.initialRoute,
        getPages: routes(),
      ),
    );
  }
}
