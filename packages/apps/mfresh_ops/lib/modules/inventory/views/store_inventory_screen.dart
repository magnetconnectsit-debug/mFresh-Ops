import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_controller.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'widgets/store_inventory_filters.dart';
import 'widgets/store_inventory_action_buttons.dart';
import 'widgets/store_inventory_table.dart';
import 'package:mfresh_ops/data/repositories/auth_repository.dart';

class StoreInventoryScreen extends StatelessWidget {
  const StoreInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InventoryController());
    final authRepo = Get.find<AuthRepository>();

    return Obx(() {
      final userPermissions = authRepo.rxUserPermissions;
      if (!userPermissions.contains('store_inventory_stock')) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppCommonAppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            showAppDrawer: true,
            hasBackButton: false,
            title: Text(
              'Store Inventory',
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
          title: controller.isSearching.value
              ? AppCommonSearchBar(
                  controller: controller.searchController,
                  hintText: 'Search items...',
                  onChanged: (v) => controller.applyFilters(),
                )
              : Text(
                  'Store Inventory',
                  style: AppTextStyle.style_18_700(color: AppColors.black),
                ),
          actions: [
            IconButton(
              onPressed: () => controller.toggleSearch(),
              icon: Icon(
                controller.isSearching.value ? Icons.close : Icons.search,
                color: AppColors.black,
                size: 24.r,
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
                const StoreInventoryFilters(),
                const StoreInventoryActionButtons(),
                SizedBox(height: 8.h),
                const StoreInventoryTable(),
              ],
            ),
          ),
        ),
      );
    });
  }
}
