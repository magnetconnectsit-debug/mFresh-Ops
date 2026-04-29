import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_textfield.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_common_export_button.dart';
import '../controllers/allotment_controller.dart';
import '../../../widgets/common_sidebar.dart';

class AllotmentScreen extends StatelessWidget {
  const AllotmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllotmentController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        hasBackButton: false,
        showAppDrawer: true,
        title: Obx(
          () => controller.isSearching.value
              ? AppCommonSearchBar(
                  controller: controller.searchController,
                  onChanged: (v) => controller.applyFilters(),
                  hintText: 'Search by Item, Source...',
                )
              : Text(
                  'Allotments',
                  style: AppTextStyle.style_18_700(color: AppColors.black),
                ),
        ),
        actions: [
          Obx(
            () => IconButton(
              onPressed: () => controller.toggleSearch(),
              icon: Icon(
                controller.isSearching.value ? Icons.close : Icons.search,
              ),
            ),
          ),
        ],
      ),
      drawer: const CommonSidebar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFiltersSection(context, controller),
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: controller.allotmentItems.length,
                itemBuilder: (context, index) {
                  final item = controller.allotmentItems[index];
                  return _buildAllotmentCard(controller, item);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllotmentCard(AllotmentController controller, AllotmentItemModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.dateOfAllotment,
                style: AppTextStyle.style_10_600(color: AppColors.grey300),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'By: ${item.allotmentBy}',
                  style: AppTextStyle.style_10_600(color: AppColors.info),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            item.itemName,
            style: AppTextStyle.style_14_700(color: AppColors.black),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildLocationBox('Source', item.source, AppColors.grey300),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Icon(Icons.arrow_forward, size: 16.r, color: AppColors.primary),
              ),
              Expanded(
                child: _buildLocationBox('Destination', item.destination, AppColors.primary),
              ),
            ],
          ),
          Divider(height: 24.h, color: AppColors.grey50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quantity',
                    style: AppTextStyle.style_10_600(color: AppColors.grey300),
                  ),
                  Text(
                    '${item.quantity} ${item.unit}',
                    style: AppTextStyle.style_12_700(color: AppColors.black),
                  ),
                ],
              ),
              _buildReverseButton(controller, item),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBox(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.style_10_600(color: AppColors.grey300),
        ),
        Text(
          value,
          style: AppTextStyle.style_11_600(color: color),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }


  Widget _buildFiltersSection(BuildContext context, AllotmentController controller) {
    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(16.r),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: AppTextStyle.style_16_700(color: AppColors.black),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: AppCommonTextField(
                  controller: controller.fromDateController,
                  titleText: 'From Month',
                  hintText: 'dd-mm-yyyy',
                  height: 32.h,
                  readOnly: true,
                  suffixIcon: Icon(Icons.calendar_today_outlined, size: 16.r),
                  onTap: () => controller.selectDate(context, controller.fromDateController),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppCommonTextField(
                  controller: controller.toDateController,
                  titleText: 'To Month',
                  hintText: 'dd-mm-yyyy',
                  height: 32.h,
                  readOnly: true,
                  suffixIcon: Icon(Icons.calendar_today_outlined, size: 16.r),
                  onTap: () => controller.selectDate(context, controller.toDateController),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              AppCommonButton(
                text: 'Apply',
                onPressed: () => controller.applyFilters(),
                height: 32.h,
                width: 80.w,
                textSize: 12.sp,
              ),
              SizedBox(width: 10.w),
              AppCommonExportButton(
                onExportExcel: () => controller.exportToExcel(),
                onExportPdf: () => controller.exportToPdf(),
                height: 32.h,
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildReverseButton(AllotmentController controller, AllotmentItemModel item) {
    return AppCommonButton(
      text: 'Reverse',
      onPressed: () => controller.reverseAllotment(item),
      height: 28.h,
      width: 70.w,
      textSize: 10.sp,
      buttonColor: AppColors.red,
    );
  }
}
