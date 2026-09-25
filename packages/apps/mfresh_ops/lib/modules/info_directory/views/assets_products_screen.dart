import 'package:core/widgets/app_common_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/assets_products_controller.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/assets_products_filters.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/assets_products_table.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';

class AssetsProductsScreen extends GetView<AssetsProductsController> {
  const AssetsProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CommonSidebar(),
      appBar: AppCommonAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        showAppDrawer: true,
        topHeader: const CommonShortcutHeader(),
        hasBackButton: false,
        toolbarHeight: 45.h,
        title: Obx(
          () => controller.isSearching.value
              ? Padding(
                  padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
                  child: AppCommonSearchBar(
                    controller: controller.searchController,
                    hintText: 'Search contacts...',
                    onChanged: (v) {
                      controller.searchQuery.value = v;
                      controller.applyFilters();
                    },
                  ),
                )
              : Text(
                  'All assets',
                  style: AppTextStyle.style_18_700(color: AppColors.black),
                ),
        ),
        actions: [
          Obx(
            () => IconButton(
              onPressed: () => controller.toggleSearch(),
              icon: Icon(
                controller.isSearching.value ? Icons.close : Icons.search,
                color: AppColors.black,
                size: 26.sp,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  AssetsProductsFilters(controller: controller),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      SizedBox(
                        height: 24.h,
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await Get.toNamed(
                              AppRoutes.createAsset,
                            );
                            if (result == true) {
                              controller.fetchAssets();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A3B8),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            elevation: 1,
                          ),
                          child: Text(
                            'Create Asset',
                            style: AppTextStyle.style_12_500(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Obx(
                        () => Container(
                          height: 24.h,
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: controller.perPage.value,
                              dropdownColor: Colors.white,
                              style: AppTextStyle.style_12_500(
                                color: AppColors.black,
                              ),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                size: 16.r,
                                color: Colors.grey.shade600,
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
                  ),
                  SizedBox(height: 16.h),
                  Expanded(child: AssetsProductsTable(controller: controller)),
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
}
