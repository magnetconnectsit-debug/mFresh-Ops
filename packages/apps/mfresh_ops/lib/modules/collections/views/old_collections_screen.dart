import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:core/widgets/app_refresh_indicator.dart';
import 'package:mfresh_ops/modules/collections/controllers/old_collections_controller.dart';
import 'widgets/old_collections_filters.dart';
import 'widgets/old_collections_summary.dart';
import 'widgets/old_collections_table.dart';
import 'package:core/utils/app_common_toast_message.dart';

class OldCollectionsScreen extends StatelessWidget {
  const OldCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OldCollectionsController());

    return Obx(() {
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
                  'Collection - Old',
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
                const OldCollectionsFilters(),
                const OldCollectionsSummary(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 24.h,
                        child: ElevatedButton(
                          onPressed: () {
                            AppCommonToastMessage.show(message: 'Exporting to Excel...', type: ToastType.info);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF389D6A), // Match the greenish color in inventory
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                            elevation: 1,
                          ),
                          child: Text('Export Excel', style: AppTextStyle.style_12_500(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                const OldCollectionsTable(),
                SizedBox(height: 24.h), // padding for bottom scrolling
              ],
            ),
          ),
        ),
      );
    });
  }
}
