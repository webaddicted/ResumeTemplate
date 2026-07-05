import 'package:get/get.dart';
import 'package:template/global/base/base_service.dart';

/// Generic in-memory / local app data holder. Extend per project.
class DataService extends BaseService {
  static DataService get to => Get.find<DataService>();

  final RxBool isLoading = false.obs;

  @override
  Future<void> onServiceInit() async {
    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 300));
    isLoading.value = false;
  }

  Future<void> refresh() async {
    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    isLoading.value = false;
  }
}
