import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import '../controllers/unit_inventory_controller.dart';
import '../../../widgets/common_sidebar.dart';
import 'widgets/unit_inventory_filters.dart';
import 'widgets/unit_inventory_table.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';

class UnitInventoryScreen extends StatelessWidget {
  const UnitInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UnitInventoryController());
    return Obx(() {
      final authRepo = Get.find<AuthRepository>();
      final userPermissions = authRepo.rxUserPermissions;

      if (!userPermissions.contains('unit_inventory_stock')) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppCommonAppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            showAppDrawer: true,
            hasBackButton: false,
            topHeader: const CommonShortcutHeader(),
            title: Text(
              'Unit Inventory',
              style: AppTextStyle.style_18_700(color: AppColors.black),
            ),
          ),
          drawer: const CommonSidebar(),
          body: Center(
            child: Text(
              'You do not have permission to view this page.',
              style: AppTextStyle.style_14_400(color: AppColors.grey300),
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppCommonAppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          showAppDrawer: true,
          hasBackButton: false,
          topHeader: const CommonShortcutHeader(),
          title: controller.isSearching.value
              ? AppCommonSearchBar(
                  controller: controller.searchController,
                  hintText: 'Search Unit or Item...',
                  onChanged: (v) => controller.applyFilters(),
                )
              : Text(
                  'Unit Inventory',
                  style: AppTextStyle.style_18_700(color: AppColors.black),
                ),
          actions: [
            IconButton(
              onPressed: () => controller.toggleSearch(),
              icon: Icon(
                controller.isSearching.value ? Icons.close : Icons.search,
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
    });
  }

  Widget _buildActionButtons(BuildContext context) {
    final controller = Get.find<UnitInventoryController>();
    return Obx(() {
      final authRepo = Get.find<AuthRepository>();
      final userPermissions = authRepo.rxUserPermissions;

      final canExport = userPermissions.contains('U_Inv_export');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      child: Row(
        children: [
          if (canExport) ...[
            SizedBox(
              height: 24.h,
              child: ElevatedButton(
                onPressed: () => controller.exportToExcel(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF389D6A),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                  elevation: 1,
                ),
                child: Text('Export Excel', style: AppTextStyle.style_12_500(color: Colors.white)),
              ),
            ),
          ],
          const Spacer(),
        ],
      ),
    );
    });
  }
}
