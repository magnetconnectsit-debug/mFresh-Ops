import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import '../controllers/unit_inventory_controller.dart';
import '../../../widgets/common_sidebar.dart';
import 'widgets/unit_inventory_filters.dart';
import 'widgets/unit_inventory_table.dart';

class UnitInventoryScreen extends StatelessWidget {
  const UnitInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UnitInventoryController());
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        showAppDrawer: true,
        hasBackButton: false,
        title: Obx(
          () => controller.isSearching.value
              ? AppCommonSearchBar(
                  controller: controller.searchController,
                  hintText: 'Search Unit or Item...',
                  onChanged: (v) => controller.applyFilters(),
                )
              : Text(
                  'Unit Inventory',
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
      body: AppRefreshIndicator(
        onRefresh: controller.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const UnitInventoryFilters(),
              _buildActionButtons(context),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: UnitInventoryTable(),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final controller = Get.find<UnitInventoryController>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          AppCommonButton(
            text: 'Export Excel',
            buttonColor: const Color(0xFF26A69A), // Green color matching screenshot
            width: 100.w,
            height: 28.h,
            onPressed: () => controller.exportToExcel(),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
