import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import '../controllers/inventory_orders_controller.dart';
import '../../../widgets/common_sidebar.dart';
import 'widgets/inventory_orders_filters.dart';
import 'widgets/inventory_orders_table.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';

class InventoryOrdersScreen extends StatelessWidget {
  const InventoryOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InventoryOrdersController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        showAppDrawer: true,
        hasBackButton: false,
        topHeader: const CommonShortcutHeader(),
        title: Obx(() {
          return controller.isSearching.value
              ? AppCommonSearchBar(
                  controller: controller.searchController,
                  hintText: 'Search order or item...',
                  onChanged: (v) => controller.applyFilters(),
                )
              : Text(
                  'Inventory Orders',
                  style: AppTextStyle.style_18_700(color: AppColors.black),
                );
        }),
        actions: [
          Obx(() => IconButton(
                onPressed: () => controller.toggleSearch(),
                icon: Icon(
                  controller.isSearching.value ? Icons.close : Icons.search,
                ),
              )),
        ],
      ),
      drawer: const CommonSidebar(),
      body: AppRefreshIndicator(
        onRefresh: controller.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const InventoryOrdersFilters(),
              _buildPaginationControls(context),
              const InventoryOrdersTable(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(BuildContext context) {
    final controller = Get.find<InventoryOrdersController>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 24.h,
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Obx(() => DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: controller.itemsPerPage.value,
                    icon: Icon(Icons.arrow_drop_down, size: 16.r),
                    isDense: true,
                    style: AppTextStyle.style_12_500(color: AppColors.black),
                    items: const [10, 25, 50, 100].map((int val) {
                      return DropdownMenuItem<int>(
                        value: val,
                        child: Text('$val per page'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        controller.setItemsPerPage(val);
                      }
                    },
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
