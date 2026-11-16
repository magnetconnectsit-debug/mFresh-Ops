import 'package:get/get.dart';
import 'package:mfresh_ops/modules/attendance_log/controllers/attendance_log_controller.dart';

class AttendanceLogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceLogController>(() => AttendanceLogController());
  }
}
