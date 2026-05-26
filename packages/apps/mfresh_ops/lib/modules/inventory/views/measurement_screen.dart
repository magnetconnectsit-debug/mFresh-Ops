import 'package:core/widgets/app_common_export_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';
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
          SizedBox(width: 16.w),
          SizedBox(width: 16.w),
        ],
      ),
      drawer: const CommonSidebar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 4.h),
            child: Row(
              children: [
                AppCommonButton(
                  text: 'Add Measurement',
                  buttonColor: AppColors.primaryBlue,
                  onPressed: () => _showAddDialog(context, controller),
                  height: 28.h,
                  width: 140.w,
                  textSize: 12.sp,
                ),
              ],
            ),
          ),
          Expanded(
            child: AppRefreshIndicator(
              onRefresh: () => controller.onRefresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Obx(() {
                  final isTableLoading = controller.isLoading.value;
                  final items = isTableLoading 
                    ? List.generate(10, (index) => 'Loading Measurement $index')
                    : controller.measurements;

                  if (items.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(32.r),
                      child: Center(
                        child: Text('No measurements found', style: AppTextStyle.style_14_400(color: AppColors.grey300)),
                      ),
                    );
                  }

                  return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Skeletonizer(
                      enabled: isTableLoading,
                      child: Table(
                        columnWidths: const {
                          0: IntrinsicColumnWidth(), // Sl No
                          1: FlexColumnWidth(1),     // Measurement
                          2: IntrinsicColumnWidth(), // Action
                        },
                        border: TableBorder.all(color: AppColors.grey50, width: 1),
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(color: AppColors.white),
                            children: [
                              _buildHeaderCell('Sl No'),
                              _buildHeaderCell('Measurement'),
                              _buildHeaderCell('Action'),
                            ],
                          ),
                          ...items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final name = entry.value;
                            return TableRow(
                              decoration: const BoxDecoration(color: AppColors.white),
                              children: [
                                _buildDataCell('${index + 1}'),
                                _buildDataCell(name),
                                _buildActionCell(controller, name, index),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Showing 1 to ${controller.measurements.length} of ${controller.measurements.length} entries',
                      style: AppTextStyle.style_14_400(color: AppColors.black),
                    ),
                    SizedBox(height: 32.h),
                  ],
                );
              }),
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Text(
        text,
        style: AppTextStyle.style_12_700(color: AppColors.black),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Text(
        text,
        style: AppTextStyle.style_12_400(color: AppColors.black),
      ),
    );
  }

  Widget _buildActionCell(MeasurementController controller, String measurementName, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Center(
        child: InkWell(
          onTap: () => _showEditDialog(Get.context!, controller, measurementName, index),
          child: Icon(
            Icons.edit_square,
            color: AppColors.primary,
            size: 16.r,
          ),
        ),
      ),
    );
  }


  void _showAddDialog(BuildContext context, MeasurementController controller) {
    controller.measurementNameController.clear();
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: const BorderSide(color: AppColors.borderColor, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Measurement',
                style: AppTextStyle.style_18_700(color: AppColors.black),
              ),
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
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.style_14_600(
                        color: AppColors.grey300,
                      ),
                    ),
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

  void _showEditDialog(BuildContext context, MeasurementController controller, String measurementName, int index) {
    controller.measurementNameController.text = measurementName;
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: const BorderSide(color: AppColors.borderColor, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Measurement',
                style: AppTextStyle.style_18_700(color: AppColors.black),
              ),
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
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.style_14_600(
                        color: AppColors.grey300,
                      ),
                    ),
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
