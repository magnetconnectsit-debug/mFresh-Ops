import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'package:mfresh_ops/data/repositories/contact_repository.dart';

class MContactBrandsController extends GetxController {
  final isLoading = false.obs;
  final brands = <Map<String, dynamic>>[].obs;
  final brandNameCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchBrands();
  }

  @override
  void onClose() {
    brandNameCtrl.dispose();
    super.onClose();
  }

  Future<void> fetchBrands() async {
    try {
      isLoading.value = true;
      final repo = Get.find<ContactRepository>();
      final result = await repo.fetchBrandList();
      brands.value = result;
    } catch (e) {
      debugPrint('Error fetching brands: $e');
      AppCommonToastMessage.show(
        message: 'Failed to fetch brands',
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitBrand({int? brandId}) async {
    if (!formKey.currentState!.validate()) {
      return false;
    } if (brandNameCtrl.text.trim().isEmpty) {
      AppCommonToastMessage.show(
        message: 'Brand Name is required',
        type: ToastType.warning,
      );
      return false;
    }

    try {
      isLoading.value = true;
      final repo = Get.find<ContactRepository>();
      final Map<String, dynamic>? response;

      if (brandId != null) {
        response = await repo.updateBrand(
          brandId: brandId,
          brandName: brandNameCtrl.text.trim(),
        );
      } else {
        response = await repo.createBrand(
          brandName: brandNameCtrl.text.trim(),
        );
      }

      if (response != null && response['status'] == true) {
        AppCommonToastMessage.show(
          message: (response['message'] ?? response['msg'])?.toString() ?? (brandId != null ? 'Brand updated successfully' : 'Brand created successfully'),
          type: ToastType.success,
        );
        return true;
      } else {
        AppCommonToastMessage.show(
          message: (response?['message'] ?? response?['msg'])?.toString() ?? 'Failed to save brand',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error saving brand: $e');
      AppCommonToastMessage.show(
        message: 'Error: ${e.toString()}',
        type: ToastType.error,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBrand(int id) async {
    try {
      final repo = Get.find<ContactRepository>();
      final response = await repo.deleteBrand(brandId: id);
      
      if (response != null && response['status'] == true) {
        AppCommonToastMessage.show(
          message: (response['message'] ?? response['msg'])?.toString() ?? 'Brand deleted successfully',
          type: ToastType.success,
        );
        fetchBrands(); // Refresh list after deleting
      } else {
        AppCommonToastMessage.show(
          message: (response?['message'] ?? response?['msg'])?.toString() ?? 'Failed to delete brand',
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint('Error deleting brand: $e');
      AppCommonToastMessage.show(
        message: 'Error: ${e.toString()}',
        type: ToastType.error,
      );
    }
  }
}
