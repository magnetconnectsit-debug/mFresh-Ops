// region Imports
import 'package:get/get.dart';
import 'package:mfresh_ops/data/repositories/selfie_attendance_repository.dart';
import 'package:mfresh_ops/modules/selfie_attendance/controllers/selfie_attendance_controller.dart';
import 'package:mfresh_ops/modules/selfie_attendance/controllers/selfie_attendance_detail_controller.dart';
// endregion

// region Bindings
class SelfieAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelfieAttendanceRepository>(
      () => SelfieAttendanceRepository(),
      fenix: true,
    );
    Get.lazyPut<SelfieAttendanceController>(
      () => SelfieAttendanceController(),
    );
  }
}

class SelfieAttendanceDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelfieAttendanceRepository>(
      () => SelfieAttendanceRepository(),
      fenix: true,
    );
    Get.lazyPut<SelfieAttendanceDetailController>(
      () => SelfieAttendanceDetailController(),
    );
  }
}
// endregion
