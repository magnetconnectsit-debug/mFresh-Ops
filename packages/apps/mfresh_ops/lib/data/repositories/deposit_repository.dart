import 'package:get/get.dart';
import 'package:mfresh_ops/core/constants/app_constants.dart';
import 'package:services/api_services.dart';
import 'dart:io';
import 'package:dio/dio.dart' as dio;

class DepositRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<Map<String, dynamic>?> getDeposits() async {
    try {
      final response = await _apiService.get(AppConstants.cashDepositList);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> storeDeposit({
    required String depositDt,
    required String actualDeposit,
    required String forMonth,
    required String remarkVal,
    required String folderPath,
    required File supervisorFile,
  }) async {
    try {
      final fileName = supervisorFile.path.split('/').last;
      final formData = dio.FormData.fromMap({
        'depositdt': depositDt,
        'actualdeposit': actualDeposit,
        'for_month': forMonth,
        'remarkval': remarkVal,
        'folder_path': folderPath,
        'supervisor_file': await dio.MultipartFile.fromFile(
          supervisorFile.path,
          filename: fileName,
        ),
      });

      final response = await _apiService.post(
        AppConstants.cashDepositStore,
        data: formData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> updateDeposit({
    required String id,
    required String depositDt,
    required String actualDeposit,
    required String forMonth,
    required String remarkVal,
    required String folderPath,
    File? supervisorFile,
  }) async {
    try {
      final dataMap = <String, dynamic>{
        'eddepoid': id,
        'depositdt': depositDt,
        'actualdeposit': actualDeposit,
        'for_month': forMonth,
        'edremarkval': remarkVal,
        'folder_path': folderPath,
      };

      if (supervisorFile != null) {
        final fileName = supervisorFile.path.split('/').last;
        dataMap['edsupervisor_file'] = await dio.MultipartFile.fromFile(
          supervisorFile.path,
          filename: fileName,
        );
      }

      final formData = dio.FormData.fromMap(dataMap);

      final response = await _apiService.post(
        AppConstants.cashDepositUpdate,
        data: formData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> deleteDeposit({required int id}) async {
    try {
      final response = await _apiService.post(
        AppConstants.cashDepositDelete,
        data: {'id': id},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
