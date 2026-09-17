import 'package:get/get.dart';
import 'package:services/api_services.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:mfresh_ops/data/models/payment_reminder/payment_reminder_model.dart';

class PaymentReminderRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<PaymentReminderResponse> getPaymentReminders({
    required String year,
    required String fromMonth,
    required String toMonth,
    required dynamic assignee,
    required dynamic status,
    required String search,
  }) async {
    try {
      final payload = {
        "year": year,
        "from_month": fromMonth,
        "to_month": toMonth,
        "assignee": assignee,
        "status": status,
        "search": search,
      };

      final response = await _apiService.post(
        AppConstants.paymentIndex,
        data: payload,
      );

      if (response is Map<String, dynamic>) {
        return PaymentReminderResponse.fromJson(response);
      }
      return PaymentReminderResponse(
        success: false,
        status: false,
        message: 'Invalid response format',
        users: [],
        paymentReminders: [],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<PaymentReminderResponse> getCompletedPayments({
    required String year,
    required String fromMonth,
    required String toMonth,
    required dynamic assignees,
    required String search,
  }) async {
    try {
      final payload = {
        "year": year,
        "from_month": fromMonth,
        "to_month": toMonth,
        "assignees": assignees,
        "search": search,
      };

      final response = await _apiService.post(
        AppConstants.completedPaymentFilter,
        data: payload,
      );

      if (response is Map<String, dynamic>) {
        return PaymentReminderResponse.fromJson(response);
      }
      return PaymentReminderResponse(
        success: false,
        status: false,
        message: 'Invalid response format',
        users: [],
        paymentReminders: [],
      );
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
