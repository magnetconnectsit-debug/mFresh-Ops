// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/routes/app_routes.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/info_directory_controller.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/info_directory_filter_card.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/info_directory_table.dart';
// endregion

// region InfoDirectoryScreen Class
class InfoDirectoryScreen extends StatelessWidget {
  const InfoDirectoryScreen({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InfoDirectoryController());

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CommonSidebar(),
      appBar: _buildAppBar(controller),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoDirectoryFilterCard(controller: controller),
                  SizedBox(height: 4.h),
                  _buildActionBar(controller),
                  SizedBox(height: 4.h),
                  Expanded(child: InfoDirectoryTable(controller: controller)),
                ],
              ),
            ),
            Obx(() {
              if (controller.isLoading.value &&
                  !controller.isRefreshing.value) {
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
  PreferredSizeWidget _buildAppBar(InfoDirectoryController controller) {
    return AppCommonAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      showAppDrawer: true,
      hasBackButton: false,
      topHeader: const CommonShortcutHeader(),
      toolbarHeight: 45.h,
      title: Row(
        children: [
          Text(
            'All Contacts',
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
  Widget _buildActionBar(InfoDirectoryController controller) {
    return Row(
      children: [
        AppCommonButton(
          text: 'Create Contact',
          buttonColor: AppColors.primary,
          textColor: AppColors.white,
          height: 22.h,
          textSize: 12.sp,
          borderRadius: 4.r,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          onPressed: () async {
            final result = await Get.toNamed(AppRoutes.createContact);
            if (result == true) {
              controller.fetchContacts();
            }
          },
        ),
        const Spacer(),
        Obx(
          () => Container(
            height: 22.h,
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
                style: AppTextStyle.style_12_500(color: AppColors.black),
                icon: Icon(
                  Icons.arrow_drop_down,
                  size: 16.r,
                  color: AppColors.grey600,
                ),
                items: [10, 20, 50, 100, 500, 1000].map((int val) {
                  return DropdownMenuItem<int>(
                    value: val,
                    child: Text('$val per page'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    controller.perPage.value = val;
                    controller.currentPage.value = 1;
                    controller.fetchContacts();
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
