import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/inventory/controllers/inventory_order_logs_controller.dart';
import 'package:mfresh_ops/modules/inventory/views/widgets/order_logs_table.dart';

class OrderLogsScreen extends StatelessWidget {
  const OrderLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InventoryOrderLogsController());

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
                  hintText: 'Search order ID, item name...',
                  onChanged: (v) => controller.allLogs.refresh(),
                )
              : Text(
                  'Order Receive Logs',
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
              SizedBox(height: 12.h),
              const OrderLogsTable(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
