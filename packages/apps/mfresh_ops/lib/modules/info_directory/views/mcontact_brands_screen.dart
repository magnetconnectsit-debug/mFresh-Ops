// region Imports
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:mfresh_ops/widgets/common_shortcut_header.dart';
import 'package:mfresh_ops/widgets/common_sidebar.dart';
import 'package:mfresh_ops/modules/info_directory/controllers/mcontact_brands_controller.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/mcontact_brands_table.dart';
import 'package:mfresh_ops/modules/info_directory/views/widgets/mcontact_brand_dialog.dart';
// endregion

// region MContactBrandsScreen Class
class MContactBrandsScreen extends StatelessWidget {
  const MContactBrandsScreen({super.key});

  // region Main Build
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MContactBrandsController());

    return Scaffold(
      backgroundColor: AppColors.white,
      drawer: const CommonSidebar(),
      appBar: _buildAppBar(context, controller),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: MContactBrandsTable(controller: controller),
        ),
      ),
    );
  }
  // endregion

  // region App Bar
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    MContactBrandsController controller,
  ) {
    return AppCommonAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      showAppDrawer: true,
      hasBackButton: false,
      topHeader: const CommonShortcutHeader(),
      titleSpacing: 16.w,
      title: Text(
        'All Brands',
        style: AppTextStyle.style_15_700(color: AppColors.black),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: AppCommonButton(
            text: 'Create Brand',
            buttonColor: AppColors.primary,
            textColor: AppColors.white,
            height: 28.h,
            textSize: 12.sp,
            borderRadius: 4.r,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            onPressed: () async {
              await showMContactBrandDialog(context, controller);
              controller.fetchBrands();
            },
          ),
        ),
      ],
    );
  }
  // endregion
}
// endregion
