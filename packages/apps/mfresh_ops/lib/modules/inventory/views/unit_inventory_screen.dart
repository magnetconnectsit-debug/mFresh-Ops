import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import '../controllers/unit_inventory_controller.dart';
import '../../../widgets/common_sidebar.dart';
import 'widgets/unit_inventory_filters.dart';
import 'widgets/unit_inventory_table.dart';
import 'widgets/unit_required_orders_dialog.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';

class UnitInventoryScreen extends StatefulWidget {
  const UnitInventoryScreen({super.key});

  @override
  State<UnitInventoryScreen> createState() => _UnitInventoryScreenState();
}

class _UnitInventoryScreenState extends State<UnitInventoryScreen> {
  late final UnitInventoryController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(UnitInventoryController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchUnitInventory();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          toolbarHeight: 45.h,
          title: Row(
            children: [
              Text(
                'Unit Inventory',
                style: AppTextStyle.style_18_700(color: AppColors.black),
              ),
              const Spacer(),
              AppCommonSearchBar(
                width: 140.w,
                controller: controller.searchController,
                hintText: 'Search',
                onChanged: (v) => controller.applyFilters(),
              ),
            ],
          ),
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
                const UnitInventoryTable(),
                SizedBox(height: 40.h),
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
              AppCommonExportButton(
                onExportExcel: () => controller.exportToExcel(),
                isLoading: controller.isExporting.value,
              ),
              SizedBox(width: 4.w),
            ],
            Obx(() {
              if (!Get.find<AuthRepository>()
                  .rxUserPermissions
                  .contains('Inv_Unit_Order')) {
                return const SizedBox.shrink();
              }
              return SizedBox(
                height: 24.h,
                child: ElevatedButton(
                  onPressed: () =>
                      UnitRequiredOrdersDialog.show(context: context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r)),
                    elevation: 1,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('Request Orders',
                      style: AppTextStyle.style_10_600(color: AppColors.white)),
                ),
              );
            }),
            SizedBox(width: 4.w),
            SizedBox(
              height: 24.h,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(AppRoutes.unitInventoryAudit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r)),
                  elevation: 1,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fact_check_outlined,
                        size: 12.r, color: AppColors.white),
                    SizedBox(width: 2.w),
                    Text('Audit',
                        style: AppTextStyle.style_10_600(color: AppColors.white)),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            Container(
              height: 24.h,
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: controller.itemsPerPage.value,
                  icon: Icon(Icons.arrow_drop_down, size: 14.r, color: AppColors.black),
                  isDense: true,
                  padding: EdgeInsets.zero,
                  style: AppTextStyle.style_10_500(color: AppColors.black),
                  items: const [10, 25, 50, 100].map((int val) {
                    return DropdownMenuItem<int>(
                      value: val,
                      child: Text('$val / page',
                          style: AppTextStyle.style_10_500(color: AppColors.black)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      controller.setItemsPerPage(val);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
