import 'package:get/get.dart';
import 'package:mfresh/data/models/unit_model.dart';
import 'package:mfresh/data/repositories/common_repository.dart';
import 'package:core/utils/app_common_toast_message.dart';

class DashboardController extends GetxController {
  final CommonRepository _commonRepository = Get.find<CommonRepository>();

  final allUnitsList = <UnitModel>[].obs;
  final isLoading = false.obs;
  final currentIndex = 0.obs;

  void onTabTapped(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    fetchUnits();
  }

  Future<void> fetchUnits() async {
    try {
      isLoading.value = true;
      final units = await _commonRepository.getAllUnits();
      allUnitsList.assignAll(units);
    } catch (e) {
      AppCommonToastMessage.show(
        message: 'Failed to load units',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
