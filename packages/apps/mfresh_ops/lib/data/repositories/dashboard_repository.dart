import 'package:get/get.dart';
import 'package:services/services.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';

class DashboardRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<dynamic> getDashboardData(Map<String, dynamic> filters) async {
    return await _apiService.post(
      AppConstants.dashboardData,
      data: filters,
    );
  }

  Future<dynamic> getComparisonData(List<Map<String, dynamic>> comparisons) async {
    return await _apiService.post(
      AppConstants.comparisonDashboardData,
      data: {'comparisons': comparisons},
    );
  }
}

