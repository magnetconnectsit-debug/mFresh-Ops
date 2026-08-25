import 'package:get/get.dart';
import 'package:services/api_services.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:mfresh_ops/data/models/payment_reminder_model.dart';

class PaymentReminderRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<PaymentReminderResponse> getPaymentReminders({
    required List<int> projectIds,
    required String unitId,
    required List<int> assigneeIds,
    required List<int> sGroupIds,
  }) async {
    try {
      final data = {
        "project_id": projectIds,
        "unit_id": unitId,
        "assignee_id": assigneeIds,
        "s_groupID": sGroupIds,
      };

      final response = await _apiService.get(
        AppConstants.paymentIndex,
        data: data,
      );
      
      // Since ApiService returns a Map<String, dynamic> typically, we parse it:
      return PaymentReminderResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
  Future<bool> addPaymentReminder(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post(
        AppConstants.paymentAdd,
        data: data,
      );
      
      if (response != null && response['status'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }
}

