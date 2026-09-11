import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:services/api_services.dart';

class AccountSubscriptionRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<Map<String, dynamic>?> fetchList({
    required String unitLocation,
    required String companyBrand,
    required List<String> account,
    required String payment,
    required String globalSearch,
    required int perPage,
    required int page,
  }) async {
    final response = await _apiService.get(
      AppConstants.accountSubscriptionList,
      data: {
        'unit_location': unitLocation,
        'company_brand': companyBrand,
        'account': account,
        'payment': payment,
        'global_search': globalSearch,
        'per_page': perPage,
        'page': page,
      },
    );
    return response as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> fetchAccountList() async {
    final response = await _apiService.get(AppConstants.accountList);
    return response as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> storeSubscription({
    required String account,
    required String brand,
    required String service,
    required String unit,
    required String city,
    required String location,
    required String customerID,
    required String email,
    required String username,
    required String password,
    required String comments,
    required String company,
    required String mobileNo,
    required String urls,
    required String remarks,
    required String planName,
    required String payment,
    required String scheduledDueDate,
    required String nextDue,
    required String lastPayment,
    required String paymentDetails,
  }) async {
    final response = await _apiService.post(
      AppConstants.accountSubscriptionStore,
      data: {
        'accnm': account,
        'brandnm': brand,
        'servicenm': service,
        'unitnm': unit,
        'citynm': city,
        'Locationnm': location,
        'CustomerID': customerID,
        'Emailval': email,
        'usernm': username,
        'passval': password,
        'Comments': comments,
        'Companynm': company,
        'MobileNo': mobileNo,
        'urlsval': urls,
        'remarksval': remarks,
        'plan_name': planName,
        'payment': payment,
        'Scheduledduedate': scheduledDueDate,
        'NextDueval': nextDue,
        'LastPayment': lastPayment,
        'PaymentDetails': paymentDetails,
      },
    );
    return response as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> updateSubscription({
    required int id,
    required String account,
    required String brand,
    required String service,
    required String unit,
    required String city,
    required String location,
    required String customerID,
    required String email,
    required String username,
    required String password,
    required String comments,
    required String company,
    required String mobileNo,
    required String urls,
    required String remarks,
    required String planName,
    required String payment,
    required String scheduledDueDate,
    required String nextDue,
    required String lastPayment,
    required String paymentDetails,
  }) async {
    final response = await _apiService.post(
      AppConstants.accountSubscriptionUpdate,
      data: {
        'id': id.toString(),
        'accnm': account,
        'brandnm': brand,
        'servicenm': service,
        'unitnm': unit,
        'citynm': city,
        'Locationnm': location,
        'CustomerID': customerID,
        'Emailval': email,
        'usernm': username,
        'passval': password,
        'Comments': comments,
        'Companynm': company,
        'MobileNo': mobileNo,
        'urlsval': urls,
        'remarksval': remarks,
        'plan_name': planName,
        'payment': payment,
        'Scheduledduedate': scheduledDueDate,
        'NextDueval': nextDue,
        'LastPayment': lastPayment,
        'PaymentDetails': paymentDetails,
      },
    );
    return response as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> deleteSubscription(int id) async {
    final response = await _apiService.post(
      AppConstants.accountSubscriptionDelete,
      data: {'id': id},
    );
    return response as Map<String, dynamic>?;
  }
}
