// region Imports
import 'package:core/utils/app_common_toast_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mfresh_ops/data/models/selfie_attendance/selfie_attendance_logs_model.dart';
import 'package:mfresh_ops/data/repositories/selfie_attendance_repository.dart';
import 'package:url_launcher/url_launcher.dart';
// endregion

// region Controller
class SelfieAttendanceDetailController extends GetxController {
  // region Dependencies & Repositories
  final SelfieAttendanceRepository _repository =
      Get.isRegistered<SelfieAttendanceRepository>()
          ? Get.find<SelfieAttendanceRepository>()
          : Get.put(SelfieAttendanceRepository());
  // endregion

  // region Observables & State Variables
  final isLoading = false.obs;
  final detailData = Rxn<SelfieAttendanceLogsData>();

  // Pass-through arguments
  final userId = ''.obs;
  final userName = ''.obs;
  final date = ''.obs;
  final dateIso = ''.obs;
  final units = ''.obs;
  // endregion

  // region Text Controllers & Focus Nodes
  final employeeController = TextEditingController();
  final dateController = TextEditingController();
  final unitsController = TextEditingController();
  final firstInController = TextEditingController();
  final lastOutController = TextEditingController();
  final totalDurationController = TextEditingController();
  final breakDurationController = TextEditingController();
  final actualDurationController = TextEditingController();
  final totalSessionsController = TextEditingController();
  final completedOpenController = TextEditingController();
  // endregion

  // region Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    _parseArguments();
    fetchLogs();
  }

  @override
  void onClose() {
    employeeController.dispose();
    dateController.dispose();
    unitsController.dispose();
    firstInController.dispose();
    lastOutController.dispose();
    totalDurationController.dispose();
    breakDurationController.dispose();
    actualDurationController.dispose();
    totalSessionsController.dispose();
    completedOpenController.dispose();
    super.onClose();
  }

  void _parseArguments() {
    final args = Get.arguments;
    if (args is Map) {
      userId.value = args['user_id']?.toString() ?? '';
      userName.value = args['user_name']?.toString() ?? '';
      date.value = args['date']?.toString() ?? '';
      dateIso.value = args['date_iso']?.toString() ?? '';
      units.value = args['units']?.toString() ?? '';
      updateSummaryControllers();
    }
  }
  // endregion

  // region API & Network Operations
  Future<void> fetchLogs() async {
    if (userId.value.isEmpty) {
      AppCommonToastMessage.show(
        message: 'Invalid User ID',
        type: ToastType.error,
      );
      return;
    }

    isLoading.value = true;
    try {
      final queryDate = date.value.isNotEmpty ? date.value : dateIso.value;
      final response = await _repository.getLogs(
        userId: userId.value,
        date: queryDate,
      );

      if (response != null && response.status && response.data != null) {
        detailData.value = response.data;
        updateSummaryControllers();
      } else {
        AppCommonToastMessage.show(
          message: response?.message ?? 'Failed to load logs',
          type: ToastType.warning,
        );
      }
    } catch (e) {
      debugPrint('SelfieAttendanceDetailController.fetchLogs Error: $e');
      AppCommonToastMessage.show(
        message: e.toString().replaceFirst('Exception: ', ''),
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
  // endregion

  // region Business Logic & Helpers
  SelfieAttendanceSummary get summary =>
      detailData.value?.summary ?? SelfieAttendanceSummary.empty();

  List<SelfieAttendanceLogItem> get logs => summary.logs;

  void updateSummaryControllers() {
    final s = summary;
    final user = detailData.value?.user;
    employeeController.text = user?.name.isNotEmpty == true
        ? user!.name
        : (userName.value.isNotEmpty ? userName.value : '—');
    dateController.text = detailData.value?.date.isNotEmpty == true
        ? detailData.value!.date
        : (date.value.isNotEmpty ? date.value : '—');
    unitsController.text = s.units.isNotEmpty == true && s.units != '—'
        ? s.units
        : (units.value.isNotEmpty ? units.value : '—');
    firstInController.text = s.firstIn?.isNotEmpty == true ? s.firstIn! : '—';
    lastOutController.text = s.lastOut?.isNotEmpty == true ? s.lastOut! : '—';
    totalDurationController.text =
        s.totalDuration?.isNotEmpty == true ? s.totalDuration! : '—';
    breakDurationController.text = s.breakDuration;
    actualDurationController.text = s.actualDuration;
    totalSessionsController.text = s.totalSessions.toString();
    completedOpenController.text = '${s.completedSessions} / ${s.openSessions}';
  }

  Future<void> openMap({
    String? mapUrl,
    String? latitude,
    String? longitude,
  }) async {
    try {
      Uri? uri;
      if (mapUrl != null && mapUrl.isNotEmpty) {
        uri = Uri.parse(mapUrl);
      } else if (latitude != null &&
          latitude.isNotEmpty &&
          longitude != null &&
          longitude.isNotEmpty) {
        uri = Uri.parse('https://www.google.com/maps?q=$latitude,$longitude');
      }

      if (uri != null) {
        final canLaunch = await canLaunchUrl(uri);
        if (canLaunch) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(uri);
        }
      } else {
        AppCommonToastMessage.show(
          message: 'Location coordinates not available',
          type: ToastType.warning,
        );
      }
    } catch (e) {
      debugPrint('openMap error: $e');
      AppCommonToastMessage.show(
        message: 'Could not open map',
        type: ToastType.error,
      );
    }
  }
  // endregion
}
// endregion
