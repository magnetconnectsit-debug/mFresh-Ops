import 'package:get/get.dart';
import 'package:mfresh_ops/modules/staff_tracking/controllers/staff_tracking_controller.dart';

class StaffTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaffTrackingController>(() => StaffTrackingController());
  }
}
