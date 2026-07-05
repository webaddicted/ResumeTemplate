import 'package:get/get.dart';
import 'package:template/controller/theme_controller.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ThemeController(), fenix: true);
  }
}
