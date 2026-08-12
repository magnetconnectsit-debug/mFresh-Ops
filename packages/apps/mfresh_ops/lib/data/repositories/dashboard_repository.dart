import 'package:get/get.dart';
import 'package:services/services.dart';

class DashboardRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<dynamic> getDashboardData(Map<String, dynamic> filters) async {
    return await _apiService.post(
      'dashboard-data',
      data: filters,
    );
  }
}
