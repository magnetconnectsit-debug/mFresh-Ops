import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/repositories/contact_repository.dart';

class MContactCompaniesController extends GetxController {
  final isLoading = false.obs;
  final companies = <Map<String, dynamic>>[].obs;
  final companyNameCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchCompanies();
  }

  @override
  void onClose() {
    companyNameCtrl.dispose();
    super.onClose();
  }

  Future<void> fetchCompanies() async {
    try {
      isLoading.value = true;
      final repo = Get.find<ContactRepository>();
      final result = await repo.fetchCompanyList();
      companies.value = result;
    } catch (e) {
      debugPrint('Error fetching companies: $e');
      AppCommonToastMessage.show(
        message: 'Failed to fetch companies',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitCompany({int? companyId}) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (companyNameCtrl.text.trim().isEmpty) {
      AppCommonToastMessage.show(
        message: 'Company Name is required',
        type: ToastType.warning,
      );
      return false;
    }

    try {
      isLoading.value = true;
      final repo = Get.find<ContactRepository>();
      final Map<String, dynamic>? response;

      if (companyId != null) {
        response = await repo.updateCompany(
          companyId: companyId,
          companyName: companyNameCtrl.text.trim(),
        );
      } else {
        response = await repo.createCompany(
          companyName: companyNameCtrl.text.trim(),
        );
      }

      if (response != null && response['status'] == true) {
        AppCommonToastMessage.show(
          message: (response['message'] ?? response['msg'])?.toString() ?? (companyId != null ? 'Company updated successfully' : 'Company created successfully'),
          type: ToastType.success,
        );
        return true;
      } else {
        AppCommonToastMessage.show(
          message: (response?['message'] ?? response?['msg'])?.toString() ?? 'Failed to save company',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error saving company: $e');
      AppCommonToastMessage.show(
        message: 'Error: ${e.toString()}',
        type: ToastType.error,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCompany(int id) async {
    try {
      final repo = Get.find<ContactRepository>();
      final response = await repo.deleteCompany(companyId: id);
      
      if (response != null && response['status'] == true) {
        AppCommonToastMessage.show(
          message: (response['message'] ?? response['msg'])?.toString() ?? 'Company deleted successfully',
          type: ToastType.success,
        );
        fetchCompanies(); // Refresh list after deleting
      } else {
        AppCommonToastMessage.show(
          message: (response?['message'] ?? response?['msg'])?.toString() ?? 'Failed to delete company',
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint('Error deleting company: $e');
      AppCommonToastMessage.show(
        message: 'Error: ${e.toString()}',
        type: ToastType.error,
      );
    }
  }
}
