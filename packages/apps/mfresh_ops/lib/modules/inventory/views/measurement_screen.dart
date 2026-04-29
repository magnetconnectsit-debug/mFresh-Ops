import 'package:core/widgets/app_common_export_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import '../controllers/measurement_controller.dart';
import '../../../widgets/common_sidebar.dart';

class MeasurementScreen extends StatelessWidget {
  const MeasurementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MeasurementController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        hasBackButton: false,
        showAppDrawer: true,
        title: const Text('Measurements'),
        actions: [
          AppCommonExportButton(
            onExportExcel: () => controller.exportToExcel(),
            onExportPdf: () => controller.exportToPdf(),
            height: 32.h,
          ),
          SizedBox(width: 8.w),
          AppCommonButton(
            text: 'Add',
            onPressed: () => _showAddDialog(context, controller),
            height: 32.h,
            width: 70.w,
            textSize: 12.sp,
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
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: controller.measurements.length,
                itemBuilder: (context, index) {
                  return _buildMeasurementCard(context, controller, index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMeasurementCard(BuildContext context, MeasurementController controller, int index) {
    final name = controller.measurements[index];
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 24.r,
            width: 24.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryVariant.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: AppTextStyle.style_12_700(color: AppColors.primaryVariant),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              name,
              style: AppTextStyle.style_14_600(color: AppColors.black),
            ),
          ),
          SizedBox(
            width: 32.w,
            height: 32.h,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.more_vert, color: AppColors.grey300, size: 18.r),
              onSelected: (value) {
              if (value == 'edit') {
                _showEditDialog(context, controller, index, name);
              } else if (value == 'delete') {
                controller.deleteMeasurement(index);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20.r, color: AppColors.info),
                    SizedBox(width: 8.w),
                    const Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20.r, color: AppColors.red),
                    SizedBox(width: 8.w),
                    const Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  void _showAddDialog(BuildContext context, MeasurementController controller) {
    controller.measurementNameController.clear();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Measurement', style: AppTextStyle.style_18_700(color: AppColors.black)),
              SizedBox(height: 20.h),
              AppCommonTextField(
                controller: controller.measurementNameController,
                titleText: 'Measurement Name',
                hintText: 'e.g. Litre',
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel', style: AppTextStyle.style_14_600(color: AppColors.grey300)),
                  ),
                  SizedBox(width: 12.w),
                  AppCommonButton(
                    text: 'Submit',
                    width: 100.w,
                    height: 36.h,
                    onPressed: () => controller.addMeasurement(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, MeasurementController controller, int index, String currentName) {
    controller.measurementNameController.text = currentName;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Measurement', style: AppTextStyle.style_18_700(color: AppColors.black)),
              SizedBox(height: 20.h),
              AppCommonTextField(
                controller: controller.measurementNameController,
                titleText: 'Measurement Name',
                hintText: 'e.g. Litre',
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel', style: AppTextStyle.style_14_600(color: AppColors.grey300)),
                  ),
                  SizedBox(width: 12.w),
                  AppCommonButton(
                    text: 'Update',
                    width: 100.w,
                    height: 36.h,
                    onPressed: () => controller.editMeasurement(index, controller.measurementNameController.text.trim()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
