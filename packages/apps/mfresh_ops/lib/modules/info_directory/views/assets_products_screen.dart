// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/assets_products_controller.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/assets_products_filters.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/assets_products_table.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
// endregion

// region AssetsProductsScreen Class
class AssetsProductsScreen extends GetView<AssetsProductsController> {
  const AssetsProductsScreen({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CommonSidebar(),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  AssetsProductsFilters(controller: controller),
                  SizedBox(height: 6.h),
                  _buildActionBar(),
                  SizedBox(height: 6.h),
                  Expanded(
                    child: AssetsProductsTable(controller: controller),
                  ),
                ],
              ),
            ),
            Obx(() {
              if (controller.isLoading.value) {
                return const CustomAppLoader();
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
  // endregion

  // region App Bar
  PreferredSizeWidget _buildAppBar() {
    return AppCommonAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      showAppDrawer: true,
      topHeader: const CommonShortcutHeader(),
      hasBackButton: false,
      toolbarHeight: 45.h,
      title: Row(
        children: [
          Text(
            'All assets',
            style: AppTextStyle.style_18_700(color: AppColors.black),
          ),
          const Spacer(),
          AppCommonSearchBar(
            width: 140.w,
            controller: controller.searchController,
            hintText: 'Search',
            onChanged: (v) {
              controller.searchQuery.value = v;
              controller.applyFilters();
            },
          ),
        ],
      ),
    );
  }
  // endregion

  // region Action Bar
  Widget _buildActionBar() {
    return Row(
      children: [
        AppCommonButton(
          text: 'Create Asset',
          icon: Icons.add,
          buttonColor: AppColors.primary,
          textColor: AppColors.white,
          height: 26.h,
          textSize: 12.sp,
          borderRadius: 4.r,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          onPressed: () async {
            final result = await Get.toNamed(
              AppRoutes.createAsset,
            );
            if (result == true) {
              controller.fetchAssets();
            }
          },
        ),
        const Spacer(),
        Obx(
          () => Container(
            height: 26.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: controller.perPage.value,
                dropdownColor: AppColors.white,
                style: AppTextStyle.style_12_500(
                  color: AppColors.black,
                ),
                icon: Icon(
                  Icons.arrow_drop_down,
                  size: 16.r,
                  color: AppColors.grey600,
                ),
                items: [10, 20, 50, 100, 500, 1000]
                    .map(
                      (val) => DropdownMenuItem<int>(
                        value: val,
                        child: Text('$val per page'),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    controller.perPage.value = val;
                    controller.fetchAssets();
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
  // endregion
}
// endregion
