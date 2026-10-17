import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_common_app_bar.dart';
import 'package:core/widgets/app_common_button.dart';
import 'package:core/widgets/app_common_search_bar.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/asset_category_controller.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/asset_category_dialog.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/asset_category_table.dart';

class AssetCategoryScreen extends StatelessWidget {
  const AssetCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AssetCategoryController());

    return Scaffold(
      backgroundColor: AppColors.white,
      drawer: const CommonSidebar(),
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
              'Asset Categories',
              style: AppTextStyle.style_18_700(color: AppColors.black),
            ),
            const Spacer(),
            AppCommonSearchBar(
              width: 140.w,
              controller: controller.searchCtrl,
              hintText: 'Search',
              onChanged: (v) {
                controller.searchQuery.value = v;
                controller.currentPage.value = 1;
              },
              onClose: () {
                controller.searchCtrl.clear();
                controller.searchQuery.value = '';
                controller.currentPage.value = 1;
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Add Category Button
              AppCommonButton(
                text: 'Add Category',
                icon: Icons.add,
                buttonColor: AppColors.primary,
                height: 28.h,
                textSize: 11.sp,
                onPressed: () => showAssetCategoryDialog(context, controller),
              ),
              SizedBox(height: 10.h),

              // Separated Table & Pagination Widget
              Expanded(child: AssetCategoryTable(controller: controller)),
            ],
          ),
        ),
      ),
    );
  }
}
