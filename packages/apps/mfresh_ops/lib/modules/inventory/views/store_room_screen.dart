import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:core/widgets/app_common_export_button.dart';
import '../controllers/store_room_controller.dart';
import '../../../widgets/common_sidebar.dart';

class StoreRoomScreen extends StatelessWidget {
  const StoreRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoreRoomController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        hasBackButton: false,
        showAppDrawer: true,
        title: Text(
          'Store\nRooms',
          style: AppTextStyle.style_16_700(color: AppColors.black),
        ),
        actions: [
          AppCommonExportButton(
            onExportExcel: () => controller.exportToExcel(),
            onExportPdf: () => controller.exportToPdf(),
            height: 32.h,
          ),
          SizedBox(width: 2.w),
          AppCommonButton(
            text: 'Add Store',
            onPressed: () => _showAddDialog(context, controller),
            height: 32.h,
            width: 90.w,
            textSize: 10.sp,
          ),
          SizedBox(width: 16.w),
        ],
      ),
      drawer: const CommonSidebar(),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                itemCount: controller.filteredStores.length,
                itemBuilder: (context, index) {
                  final store = controller.filteredStores[index];
                  return _buildStoreCard(context, controller, store, index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(
    BuildContext context,
    StoreRoomController controller,
    StoreRoomModel store,
    int index,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              store.siNo.toString(),
              style: AppTextStyle.style_12_500(color: AppColors.primary),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              store.storeName,
              style: AppTextStyle.style_14_600(color: AppColors.black),
            ),
          ),
          AppCommonButton(
            text: 'Edit',
            onPressed: () => _showEditDialog(context, controller, store, index),
            height: 28.h,
            width: 60.w,
            textSize: 10.sp,
            buttonColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, StoreRoomController controller) {
    controller.storeNameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Add Store Room', style: AppTextStyle.style_14_700()),
        content: AppCommonTextField(
          controller: controller.storeNameController,
          titleText: 'Store Name',
          hintText: 'Enter store name',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyle.style_14_500(color: AppColors.grey300),
            ),
          ),
          AppCommonButton(
            text: 'Add',
            onPressed: () => controller.addStore(),
            width: 80.w,
            height: 36.h,
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    StoreRoomController controller,
    StoreRoomModel store,
    int index,
  ) {
    controller.storeNameController.text = store.storeName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Edit Store Room', style: AppTextStyle.style_14_700()),
        content: AppCommonTextField(
          controller: controller.storeNameController,
          titleText: 'Store Name',
          hintText: 'Enter store name',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyle.style_14_500(color: AppColors.grey300),
            ),
          ),
          AppCommonButton(
            text: 'Update',
            onPressed: () => controller.editStore(
              index,
              controller.storeNameController.text,
            ),
            width: 80.w,
            height: 36.h,
          ),
        ],
      ),
    );
  }
}
