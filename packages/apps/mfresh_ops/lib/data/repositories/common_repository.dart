import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:services/api_services.dart';
import 'package:mfresh_ops/data/models/models.dart';

class CommonRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<AssigneeModel>> getAllAssignees({String? groupId}) async {
    try {
      final response = await _apiService.post(
        AppConstants.allAssignee,
        data: {
          if (groupId != null && groupId.isNotEmpty) 'group_id': groupId,
        },
      );

      if (response != null && (response['status'] == 'success' || response['status'] == true)) {
        final List data = response['data'] ?? [];
        return data.map((e) => AssigneeModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
} // endregion
